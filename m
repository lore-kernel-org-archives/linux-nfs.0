From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 21 Jan 2008 13:19:30 -0500
Message-ID: <200801211819.m0LIJU6Y017173@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond.Myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57127 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403AbYAUSUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 13:20:07 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JH1Fc-0006mI-Aq
	for linux-nfs@vger.kernel.org; Tue, 22 Jan 2008 05:20:04 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since around 2.6.24-rc5 or so I've had an occasional problem: I get an
ESTALE error on the mount point after setting up a localhost exported mount
point, and trying to mkdir something there (this is part of my setup scripts
prior to running unionfs regression tests).

I'm CC'ing both client and server maintainers/list, b/c I'm not certain
where the problem is.  The problem doesn't exist in 2.6.23 or earlier stable
kernels.  It doesn't appear in nfs4 either, only nfs2 and nfs3.

The problem is seen intermittently, and is probably some form of a race.  I
was finally able to narrow it down a bit.  I was able to write a shell
script that for me reproduces the problem within a few minutes (I tried it
on v2.6.24-rc8-74-ga7da60f and several different machine configurations).

I've included the shell script below.  Hopefully you can use it to track the
problem down.  The mkdir command in the middle of the script is that one
that'll eventually cause an ESTALE error and cause the script to abort; you
can run "df" afterward to see the stale mount points.

Notes: the one anecdotal factor that seems to make the bug appear sooner is
if you increase the number of total mounts that the script below creates
($MAX in the script).

Hope this helps.

Thanks,
Erez.


#!/bin/sh
# script to tickle a "stale filehandle" mount-point bug in nfs2/3
# Erez Zadok.

# mount flags
FLAGS=no_root_squash,rw,async
# max no. of nfs mounts (each using a loop device)
MAX=6
# total no. of times to try test
COUNT=1000

function runcmd
{
    echo "CMD: $@"
    $@
    ret=$?
    test $ret -ne 0 && exit $ret
}

function doit
{
    for c in `seq 0 $MAX`; do
	runcmd dd if=/dev/zero of=/tmp/fs.$$.$c bs=1024k count=1 seek=100
	runcmd losetup /dev/loop$c /tmp/fs.$$.$c
	runcmd mkfs -t ext2 -q /dev/loop$c
	runcmd mkdir -p /n/export/b$c
	runcmd mount -t ext2 /dev/loop$c /n/export/b$c
	runcmd exportfs -o $FLAGS localhost:/n/export/b$c
	runcmd mkdir -p /n/lower/b$c
	runcmd mount -t nfs -o nfsvers=3 localhost:/n/export/b$c /n/lower/b$c
    done

    # this mkdir command will eventually cause an ESTALE error on the mnt pt
    for c in `seq 0 $MAX`; do
	runcmd mkdir -p /n/lower/b$c/dir
    done

    # check if "df" prints" "stale file handle"
    for i in `seq 1 10` ; do
	sleep 0.1
	echo -n "."
	if test -n "`df 2>&1 | grep -i stale`" ; then
	    df
	    exit 123
	fi
    done
    echo

    for c in `seq 0 $MAX`; do
	runcmd umount /n/lower/b$c
	runcmd exportfs -u localhost:/n/export/b$c
	runcmd umount /n/export/b$c
	runcmd losetup -d /dev/loop$c
	runcmd rm -f /tmp/fs.$$.$c
    done
}

count=$COUNT
while test $count -gt 0 ; do
    echo "------------------------------------------------------------------"
    echo "COUNT $count"
    doit
    let count=count-1
done
##############################################################################

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

