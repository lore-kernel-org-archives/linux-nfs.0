From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: why there is no "s_export_op" in nfs_super_block?
Date: Tue, 4 Nov 2008 17:36:38 -0500
Message-ID: <20081104223638.GA16121@fieldses.org>
References: <200810310856000017530@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: lioupayphone <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49503 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754749AbYKDWgj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2008 17:36:39 -0500
In-Reply-To: <200810310856000017530@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 31, 2008 at 08:56:20AM +0800, lioupayphone wrote:
> Hi, linux-nfs
> 	
> 	i have a question about NFS. 
> 	say, i have three different machines, Machine-1 is a NFS Server who exported its directory "/home/pub" to Machine-2, which mounted "mount -t nfs Machine-1:/home/pub /mnt/pub/".
> 
> 	i want Machine-2 to be a NFS Server which exports its directory "/mnt/pub" to Machine-3, permission denied when i execute "mount -t nfs Machine-2:/mnt/pub/ /mnt/" on Machine-3.
> 	( btw : all the three machines are of linux 2.6.17-1, a little old kernel :-) )
> 
> 	i browsed the code of 2.6.17-1 and found check_export() in fs/nfsd/exports.c , who told me there are two reasons for that :
> 	
> 	/* There are two requirements on a filesystem to be exportable.
> 	 * 1:  We must be able to identify the filesystem from a number.
> 	 *       either a device number (so FS_REQUIRES_DEV needed)
> 	 *       or an FSID number (so NFSEXP_FSID needed).
> 	 * 2:  We must be able to find an inode from a filehandle.
> 	 *       This means that s_export_op must be set.
> 	 */
> 
> 	i think if i set "/home/pub Machin-2(sync,root_squash,fsid=1)" and "/mnt/pub Machine-2(sync,root_squash,fsid=2)" individually in "/etc/exports" of Machine-1 and Machine-2, the requirement-1 will be meet.
> 	but nfs_fill_super() failed to register its s_export_op. why? i am puzzled. thank you for your suggestions and explanations. :-)

What you're asking to do is to re-export an nfs filesystem over nfs.

That's not currently supported with linux, and there aren't plans to
support it any time soon.

There are userspace nfs servers that might this, though I don't know
what their status--they don't seem to be maintained much and probably
don't have a lot of features.

--b.
