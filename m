From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: The next step: nfsvers=4
Date: Thu, 19 Mar 2009 09:34:36 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com>
References: <49C2704F.5050303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Steve Dickson" <SteveD@redhat.com>,
	"linux NFS Mailing list" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7996 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755431AbZCSQfM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 12:35:12 -0400
In-Reply-To: <49C2704F.5050303-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com] 
> Sent: Thursday, March 19, 2009 9:18 AM
> To: linux NFS Mailing list
> Subject: The next step: nfsvers=4
> 
> As I see it, the next step to seamlessly move to V4 as the 
> default is to make 'mount -o nfsvers=4' actually do a v4 mount... 
> 
> There are two obvious place we can make this change.
> In the kernel and/or in the mount command... 
> 
> Looking at the kernel, since v3 and v4 truly two different 
> file systems its seems a bit late for the nfs_get_sb() to all 
> of sudden have to change file system type. Meaning when 
> nfs_get_sb() sees the "nfsvers=4" somehow it would have to 
> back out and call nfs4_get_sb(), which obviously is a bit hacky.... 
> 
> Now I guess we could have one nfs_get_sb() for both v3 and v4.
> Where the nfs_get_sb() could peek into the options data to 
> see which version is needed. This would also mean the mount 
> command would always have to set a version so when the "nfsvers=" 
> options is not set, the kernel would know which version to use.
> Again, this feels a bit hacky as well but doable... 
> 
> At least to me, what seems like the best option is to have 
> the mount.nfs binary early on intercept "nfsvers=4" option 
> and then change the fs_type to "nfs4", which would allow 
> everything to "trickle down" as it does today... Again to me, 
> that seem like the least intrusive way to do it...
> 
> Comments? Is there other ways?

Whichever way it's done, if v4 becomes the default, don't forget to also
make the default behavior be that the system will fall back and try a v3
mount if v4 isn't available.  Otherwise you'll break a huge percentage
of your user base.  Of course then you also have to deal with the
semantics of how to specifify "only v4" vs. "try v4 first and fall
back".

> 
> steved.
> 
>  
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
