From: CJ Kucera <pez@apocalyptech.com>
Subject: NFS Causing issues with Gimp XCF files?
Date: Thu, 8 Nov 2007 15:54:04 -0600
Message-ID: <20071108215404.GA8331@apocalyptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqFK8-0005y5-NZ
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 13:54:04 -0800
Received: from mail.apocalyptech.com ([65.99.222.156])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqFKA-0000nV-S5
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 13:54:08 -0800
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

Hello, list.

I've been encountering a problem on my Linux machine running Gimp 2.4.1 [1]
where XCF files that I save are occasionally corrupt, and can't be
loaded again into the same program.  I'm 99% sure that this is something
NFS-related, since this problem occurs only on my NFS shares, and never
when I'm saving to my local hard drive.  I noticed this problem in Gimp
2.4.0 as well (it may have been happening in some of the 2.3 development
versions as well, though I didn't notice).

Mostly right now I'd just like to find somebody other than me who can
reproduce the problem.  I've put some files up at
http://apocalyptech.com/media/gimp/ -

  * goinonboat.xcf - a Gimp file saved in an earlier version of Gimp
  * goinonboat2.xcf - The same file, after I've saved to an NFS share
  * dimension.png - The binary differences between the two files.

... so if somebody has Gimp 2.4.0 or 2.4.1 available, would you mind
loading up goinonboat.xcf, saving it to an NFS share, and then try to
have Gimp re-open the image?

It's interesting (to me) to note that the differences are all in the
width/height/bpp values writen by gimp's xcf_save_hierarchy() function
from app/xcf/xcf-save.c.  [2] Instead of writing the correct
width/height/bpp values, it ends up being zeros when the file is finally
closed.  I've added in various debugging statements, and loaded up a
debug build of gimp into gdb to trace through, and in all cases, the
values being passed into the actual fwrite() calls are correct -
something ends up writing them inappropriately in the end, though.

There *is* some fseek()ing going on during that part of the save
process, and I've found that the situation improves (though not
completely) when I start throwing in fflush() statements - so far, with
liberal use of fflush() I've been able to make it so that only the
"width" parameter ends up being zero.

Both the NFS server and my client machine (where I'm running gimp) are
running vanilla 2.6.23.1 kernels, and nfs-utils 1.1.0.  I'll upgrade to
1.1.1 in a little bit, but I was observing the same problems with an
earlier version as well.  The kernel options are:

	CONFIG_NFS_FS=y
	CONFIG_NFS_V3=y
	# CONFIG_NFS_V3_ACL is not set
	# CONFIG_NFS_V4 is not set
	# CONFIG_NFS_DIRECTIO is not set
	CONFIG_NFSD=y
	CONFIG_NFSD_V3=y
	# CONFIG_NFSD_V3_ACL is not set
	# CONFIG_NFSD_V4 is not set
	CONFIG_NFSD_TCP=y
	CONFIG_NFS_COMMON=y

The mount options don't seem to have any bearing on it - I generally
mount with "bg,intr,timeo=1,wsize=8192,rsize=8192,nolock,nfsvers=3" but
if I just do a bare mount without those options, I see the same thing.
And again, whenever I try this save on a local filesystem, the files
come out identical.

Thanks in advance,
CJ

[1] http://www.gimp.org/

[2] Notably - the image is 640x480, which in hex is 0x0280 by 0x01E0 -
    the 0x8E by 0x4B difference is from another, smaller layer inside
    the image file.

-- 
WOW: Flemmy            |   "The ships hung in the sky in much the same
pez@apocalyptech.com   |    way that bricks don't." - Douglas Adams,
24.24.2.3171           |     _The Hitchhiker's Guide To The Galaxy_

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
