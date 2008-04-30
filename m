From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] NFS/LSM: Make NFSv4 set LSM mount options
Date: Wed, 30 Apr 2008 12:47:20 -0400
Message-ID: <1209574040.2982.19.camel@localhost.localdomain>
References: <1204744818.3216.254.camel@localhost.localdomain>
	 <1208441091.2985.8.camel@localhost.localdomain>
	 <Xine.LNX.4.64.0804180911570.23675@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, chuck.lever@oracle.com,
	akpm@linux-foundation.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936AbYD3QsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:48:08 -0400
In-Reply-To: <Xine.LNX.4.64.0804180911570.23675-RC8Ws/H8zzudju81dFSl6rpzq4S04n8Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-04-18 at 09:12 +1000, James Morris wrote:
> On Thu, 17 Apr 2008, Eric Paris wrote:
> 
> > NFSv3 get_sb operations call into the LSM layer to set security options
> > passed from userspace.  NFSv4 hooks were not originally added since it
> > was reasonably late in the merge window and NFSv3 was the only thing
> > that had regressed (v4 has never supported any LSM options)
> > 
> > This patch makes NFSv4 call into the LSM to set security options rather
> > than just blindly dropping them with no notice to the user as happens
> > today.  This patch was tested in a simple NFSv4 environment with the
> > context= option and appeared to work as expected.
> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Acked-by: James Morris <jmorris@namei.org> 

Would any of the NFS people please ack and push this patch to linus?  I
don't want to ship 2.6.26 with NFSv4 continuing to just silently drop
LSM mount options.

Thanks
-Eric

