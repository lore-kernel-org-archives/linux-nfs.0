From: Frank Cusack <fcusack@fcusack.com>
Subject: nfs_refresh_inode: inode number mismatch (bug)
Date: Mon, 2 Jun 2003 01:37:31 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030602013731.B18730@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-239-45-4.google.com ([216.239.45.4])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Mkp2-0005X0-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Jun 2003 01:37:40 -0700
To: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

I'm using a frankenstein kernel, 2.4.21-rc3 with some -ac bits,
and 2.5.69 NFS+RPC backported to it.  Like the CITI kernel (for krb5),
but a little more aggressive on the bits backported.

I've found an issue with nfs_rmdir(), at least that's where I think it is.
Consider these two shell sequences:

	    1				    2

	cd /nfs				cd /nfs
	mkdir tmp
	echo foo > tmp/foo
	less tmp/foo
	 [less waits for input]
					rm -rf tmp
	'v'
	 [vi tries to access tmp/foo]

At this point, inode.c:__nfs_refresh_inode() prints the "inode number
mismatch" error.  AFAICT, this is just noise, but the noise is driving
me crazy. :-)  I'm using fsstress and I can't tell if the messages are
all because of this problem, or if my backport is bad as well.

Now, if sequence 2 is run on a different machine, there is no error!
So that hints to me that the local cache just needs to be cleared,
perhaps in nfs_rmdir() or maybe in nfs_unlink()/nfs_safe_remove().
I've tried a few things, but I'm not familiar enough with the code
and am not making headway.

The stock 2.4.20 has this problem as well.  I haven't tried any 2.5
kernels.  The 2.2 kernel doesn't have this problem, because it doesn't
allow you to unlink a .nfsXXX file while it's open (and therefore you
cannot remove the dir); clearly incorrect behavior.

This is against a netapp server, although I can't see how the server would
matter.

Thanks for any advice, guidance, or hopefully a fix!  BTW, I'm interested
to hear what tools folks use to stress NFS.

/fc


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
