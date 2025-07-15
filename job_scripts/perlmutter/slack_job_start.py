#!/usr/bin/env python
import json
import sys
import subprocess
import shlex
import os.path

def slack_post(name, channel, message, webhook):

    payload = {}

    payload["channel"] = channel
    #payload["username"] = name
    payload["text"] = message
    payload["link_names"] = 1
    s = json.dumps(payload)

    cmd = f"curl -X POST --data-urlencode 'payload={s}' {webhook}"

    run(cmd)


def run(string, stdin=False, outfile=None, store_command=False, env=None,
        outfile_mode="a", log=None):

    # shlex.split will preserve inner quotes
    prog = shlex.split(string)
    if stdin:
        p0 = subprocess.Popen(prog, stdin=subprocess.PIPE,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, env=env)
    else:
        p0 = subprocess.Popen(prog, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, env=env)

    stdout0, stderr0 = p0.communicate()
    if stdin:
        p0.stdin.close()
    rc = p0.returncode
    p0.stdout.close()

    if outfile is not None:
        try:
            cf = open(outfile, outfile_mode)
        except OSError:
            log.fail("  ERROR: unable to open file for writing")
        else:
            if store_command:
                cf.write(string)
            for line in stdout0:
                cf.write(line)
            cf.close()

    return stdout0, stderr0, rc


def doit():

    try:
        f = open(os.path.expanduser("~/.slack.webhook"))
    except OSError:
        sys.exit("ERROR: unable to open webhook file")
    else:
        webhook = str(f.readline())
        f.close()

    message = sys.argv[1]
    channel = sys.argv[2]

    if not (channel.startswith("#") or channel.startswith("@")):
        channel = f"#{channel}"

    slack_post("bender", channel, message, webhook)


if __name__ == "__main__":
    doit()
