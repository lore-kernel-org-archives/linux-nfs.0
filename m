From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] kNFSd: Fixes a problem with inode clean up for vxfs
Date: Thu, 7 Aug 2003 09:29:33 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16177.36701.340897.187670@gargle.gargle.HOWL>
References: <3F3128A4.8030305@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kXix-000425-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 16:29:43 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By note With Smtp ;
	Thu, 7 Aug 2003 09:29:33 +1000
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Wednesday August 6
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

On Wednesday August 6, SteveD@redhat.com wrote:
> This a patch I've received from Veritas. Supposedly they have
> already submitted this but I can't seem to find it in any 2.4 trees..
> 
> Does anybody recognize this and are there any known issues with it?

The patch is probably ok.
Both the current code and the new code are "wrong" as they assume
something about the setting of d_op, which only the filesystem could
know.
The current code assumes it will always be NULL.
The new code assumes it will be uniform within the filesystem.

Neither of these are certain to be true, but the later covers all
filesystems that the former covers and more, so it is safer.

It is not tecnically necessary as any filesystem in free to define
their fh_to_dentry operation to return a dentry that was not
DCACHE_NFSD_DISCONNECTED, and then this code would never be called.
The easiest way to write a fh_to_dentry that did this would be to copy
slabs of code out of nfsd/nfsfh.c, but there might be GPL issues if
Veritas did that.

All this is handled quite differently in 2.6 so it isn't an issue
there.

I would say "accept the patch".  I might even submit it for 2.4.23...

NeilBrown



> 
> The Problem: The nfsd_findparent creates a dentry using d_alloc_root. 
> The d_op
> vector pointer in this dentry is not initialized. Hence filesystems that 
> supply
> the vector have a problem. nfs exports of such filesystems do not work
> correctly under memory pressure.  vxfs, vfat, ntfs are amongst the 
> filesystems
> affected by the bug.  Need redhat to fix nfsd code in their kernels. 
> Ideally
> a kernel needs to ask a filesystem to setup a d_op vector.  An entry point
> into a filesystem for doing this job doesn't exist. We can work around the
> problem by copying d_op vector pointer from the child of the dentry, whose
> d_op vector is correct.
> 
> 
> The Patch:
> 
> --- ./fs/nfsd/nfsfh.c.diff      Wed Jul  2 13:17:35 2003
> +++ ./fs/nfsd/nfsfh.c   Tue Jul 29 04:45:43 2003
> @@ -303,6 +303,7 @@ struct dentry *nfsd_findparent(struct de
>                        if (pdentry) {
>                                igrab(tdentry->d_inode);
>                                pdentry->d_flags |= 
> DCACHE_NFSD_DISCONNECTED;
> +                              pdentry->d_op = child->d_op;
>                        }
>                }
>                if (pdentry == NULL)
> 
> SteveD.
> 


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
