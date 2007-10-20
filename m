From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Fri, 19 Oct 2007 22:33:05 -0400
Message-ID: <200710200233.l9K2X5qx015844@agora.fsl.cs.sunysb.edu>
References: <1192830752.7466.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de,
	Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ij49S-0006rr-Kw
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:33:23 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ij49W-0007pP-Qi
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 19:33:28 -0700
In-reply-to: Your message of "Fri, 19 Oct 2007 17:52:32 EDT."
	<1192830752.7466.32.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trond, good news.  I was able to narrow down the problem to purely the
client-side, probably dcache/readdir related, and I have a shell script that
deterministically triggers the problem each time for me (this is a FC6 image
under Vmware 6.0.1).  Here's a short shell script which reliably triggers
the "lost files" problem -- I create a file via nfs2 on the client side, and
sometimes it doesn't show up in readdir, but it is there if you stat it
directly.

BTW, since this is a client-side bug, I also tried your last set of posted
client patches for Linus, but it didn't help.

Happy hunting. :-)

Erez.

##############################################################################
#!/bin/sh

dd if=/dev/zero of=/tmp/fs.$$.0 bs=1024k count=1 seek=100
losetup /dev/loop0 /tmp/fs.$$.0
mkfs -t ext2 -q /dev/loop0
mkdir -p /n/export/b0
mount -t ext2 /dev/loop0 /n/export/b0
exportfs -o no_root_squash,rw localhost:/n/export/b0
mkdir -p /n/client/b0
mount -t nfs -o nfsvers=2 localhost:/n/export/b0 /n/client/b0

count=0
while true; do
    cfile="/n/client/b0/F.$count"

    if touch $cfile ; then
	echo $cfile created
    else
	echo "touch $cfile failed"
	exit 1
    fi

    if `ls -1 /n/client/b0 | egrep -q F.$count'$'` ; then
	:
    else
	echo "$cfile doesn't exist (but it should)"
	ls -l /n/client/b0
	ls -l /n/export/b0
	stat $cfile
	exit 1
    fi

    let count=count+1
done
##############################################################################

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
