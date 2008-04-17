From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] NFS/LSM: Make NFSv4 set LSM mount options
Date: Fri, 18 Apr 2008 09:12:24 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804180911570.23675@us.intercode.com.au>
References: <1204744818.3216.254.camel@localhost.localdomain>
 <1208441091.2985.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, chuck.lever@oracle.com,
	akpm@linux-foundation.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:46085 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752153AbYDQXNO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2008 19:13:14 -0400
In-Reply-To: <1208441091.2985.8.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Apr 2008, Eric Paris wrote:

> NFSv3 get_sb operations call into the LSM layer to set security options
> passed from userspace.  NFSv4 hooks were not originally added since it
> was reasonably late in the merge window and NFSv3 was the only thing
> that had regressed (v4 has never supported any LSM options)
> 
> This patch makes NFSv4 call into the LSM to set security options rather
> than just blindly dropping them with no notice to the user as happens
> today.  This patch was tested in a simple NFSv4 environment with the
> context= option and appeared to work as expected.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: James Morris <jmorris@namei.org> 


-- 
James Morris
<jmorris@namei.org>
