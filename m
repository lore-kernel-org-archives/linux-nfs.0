From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Adding mount option to kernel for NFS filesystem
Date: Thu, 30 Apr 2009 14:58:16 -0400
Message-ID: <20090430145816.7761131b@barsoom.rdu.redhat.com>
References: <49F8884A.8050402@oudelohuis.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Gertjan Oude Lohuis <gertjan-yZ1RIXqxfwWWrUy98/Atqw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35663 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756460AbZD3S61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 14:58:27 -0400
In-Reply-To: <49F8884A.8050402-yZ1RIXqxfwWWrUy98/Atqw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 29 Apr 2009 19:03:06 +0200
Gertjan Oude Lohuis <gertjan-yZ1RIXqxfwWWrUy98/Atqw@public.gmane.org> wrote:

> Hi guys,
> 
> For fun and learning purposes I'm trying to add an mountflag for
> NFS-mounts to the kernel and mount. The flag's semantics are identical
> to ac/noac: 'flag' is default but has no special meaning, 'noflag'
> triggers a certain action.
> 
> I have a small question about adding the flag to
> include/linux/nfs_mount.h. Since NFS_MOUNT_FLAGMASK is defined as
> 0xFFFF, and all bits up until 0xFFFF are occupied by existing
> NFS_MOUNT-flags, how could I add my own flag?
> Would it be ok to define NFS_MOUNT_FLAGMASK as 0xFFFFF and my own flag
> as 0x10000? Or will this have other side effects? It seems to be working
> though ;-).
> How would this be done if a real flag should be added by kernel maintainers?
> 
> I guess another option would be to create a new entry in the
> nfs_mount_data struct and treat it as an option (rsize-, wsize-,
> timeo-alike), but I'd like to do keep it the same as other flags.
> 
> Please advice! ;-)
> Thanks in advance for your time.
> 
> Sincerely,
> Gertjan
> 

It's probably better to post questions like this to
linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org cc'ing that on the response...

Newer kernels and mount.nfs progs use text-based mount options by
default. My suggestion would be to avoid worrying about the legacy
mount option code and to just make the new option work with the text
based ones only.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
