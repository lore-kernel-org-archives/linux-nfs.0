From: Bernd Schubert <bernd-schubert@web.de>
Subject: nfsd-fh: found a name that I didn't expect
Date: Fri, 28 Mar 2003 18:28:55 +0100
Message-ID: <200303281828.55093.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: reiserfs-list@namesys.com
Return-path: <reiserfs-list-return-13412-reiserfs=m.gmane.org@namesys.com>
list-help: <mailto:reiserfs-list-help@namesys.com>
list-unsubscribe: <mailto:reiserfs-list-unsubscribe@namesys.com>
list-post: <mailto:reiserfs-list@namesys.com>
Errors-To: flx@namesys.com
To: <nfs@lists.sourceforge.net>
List-ID: <nfs.lists.sourceforge.net>

Hi,

due to hardware problems I just started our fall back server and got these 
messages for 2 files:

nfsd-fh: found a name that I didn't expect: bin/uptime
nfsd-fh: found a name that I didn't expect: bin/uptime
nfsd: last server has exited
nfsd: unexporting all filesystems
nfsd-fh: found a name that I didn't expect: lib/libident.so.0
nfsd-fh: found a name that I didn't expect: lib/libident.so.0

Well, just a small explanation how our fall back-solution works:
	The server exports '/' (hda5) via nfs to all clients and via nbd to one of 
its clients (the fall back server) . The exporting via nbd is used for 
mirroring the device via a cron job (by "dd'ing" the device).
The cron-job script also executes a 'reiserfsck --fix-fixable' and afterwards 
a 'reiserfsck --check', so except doing the partionchecks, both devices 
should be identical.
However, when I started the fall-back server, it showed the messages for these 
2 files and the clients got I/O errors for these files.

The solution was to stop the nfs-server, copy the files, delete the old ones 
and move the copies back to the old names (just as I'm used to be to do when 
this happens to directories served by ClusterNFS).

Any ideas how we can prevent this in the future ?


Thanks,
	Bernd
