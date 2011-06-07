Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356Ab1FGURL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 16:17:11 -0400
Message-ID: <4DEE873F.70607@RedHat.com>
Date: Tue, 07 Jun 2011 16:17:03 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] rpc.mountd: let mountd consult /etc/services for port
References: <4DAD48C7.9090808@cn.fujitsu.com> <4DE0C380.7040608@cn.fujitsu.com> <20110528132953.GA8525@merit.edu> <D3F4AA10-8A35-4600-815B-D63CB7EF7315@oracle.com> <20110528164502.GA9188@merit.edu>
In-Reply-To: <20110528164502.GA9188@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/28/2011 12:45 PM, Jim Rees wrote:
> Chuck Lever wrote:
> 
>   So, we could also address this by getting rid of the legacy RPC behavior
>   instead.  However, in cases like this, I typically choose to stick with
>   legacy behavior, since that improves backwards compatibility.  It already
>   works like this for legacy RPC builds, so in some sense we are stuck with
>   it.
> 
> Ok.  I remember the earlier discussion but forgot that the patch simply
> restores older behavior that was changed by tirpc.  In that case I'll go
> along with Mi's patch.
I am all for restoring the older behavior, but unfortunately this patch
does not do it. 

I when back and took a look at how the  nfs-utils-1.2.2 code worked.
While its true both mountd and statd read ports from /etc/service, 
they did not fail when those ports were already taken. They just 
bound to random ephemeral ports, which is probably the reason none of 
us noticed they were reading ports out of /etc/services. With
Mi's patch, both daemons fail when the ports in /etc/service are
already taken. 

Mi, unfortunately I am not going to have any cycles to look
at this, due to the upcoming Bakeathon. So, could you please,
look into why the 1.2.2 recovered when ports in /etc/services
were taken and your patch does not.

tia,

steved.
 
