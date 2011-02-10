Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab1BJVl0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Feb 2011 16:41:26 -0500
Date: Thu, 10 Feb 2011 16:41:26 -0500
To: Asdo <asdo@shiftmail.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to separate mount rights in nfsv4
Message-ID: <20110210214126.GB29900@fieldses.org>
References: <4D534394.2050404@shiftmail.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D534394.2050404@shiftmail.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 10, 2011 at 02:47:00AM +0100, Asdo wrote:
> Hello,
> it's not clear to me how I can allow different access to different
> machines in NFSv4.
> Because nfsv4 needs a root export with fsid=0, and all other mounts
> should be below that.
> 
> However, if the line with fsid=0 is not mountable to all nodes, also the
> mounts below it will fail.
> And if the line with fsid=0 is mountable to all nodes, all further lines
> can provide no additional security!
> 
> Example; this is my current export:
> 
> /virtual_machines/kvm/export   
> 10.48.0.0/24(rw,no_root_squash,async,subtree_check,fsid=0)
> /virtual_machines/kvm/export/hwnode1  
> 10.48.0.10(rw,no_root_squash,async,subtree_check)
> /virtual_machines/kvm/export/hwnode2  
> 10.48.0.11(rw,no_root_squash,async,subtree_check)
> 
> I have two hardware nodes for virtual machines. Ideally each one of them
> should be able to mount only its subdirectory, but the export shown
> above is the only working one I could create.
> However with the above export file the root user on hwnode1 can directly
> mount /virtual_machines/kvm/export and see everything, even the files
> that were for hwnode2 only.
> OTOH if I set my fsid=0 line so that it's not mountable (e.g. changing
> the IP or netmask), all lines below it stop working.

Recent distros allow you to specify NFSv4 exports as you do NFSv2/v3
exports, without the need for the explicit fsid=0 export.  I think that
will eliminate the problem you're seeing.

However, I'd strongly recommend against use of subtree_check, which can
cause unnecessary ESTALE's when files are renamed.

It would be better to put hwnode1 and hwnode2 on different filesystems.

--b.

> 
> How should I do?
> 
> Thanks for your help
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
