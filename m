Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814Ab1ITLTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 07:19:15 -0400
Date: Tue, 20 Sep 2011 07:22:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Subject: Re: [PATCH v4 4/8] SUNRPC: setup rpcbind clients if service
 requires it
Message-ID: <20110920072206.117db4ce@corrin.poochiereds.net>
In-Reply-To: <20110920101404.9861.83097.stgit@localhost6.localdomain6>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
	<20110920101404.9861.83097.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Sep 2011 14:14:04 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> New function ("svc_uses_rpcbind") will be used to detect, that new service will
> send portmapper register calls. For such services we will create rpcbind
> clients and remove all stale portmap registrations.
> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
> in case of this field wasn't initialized earlier. This will allow to destroy
> rpcbind clients when no other users of them left.
> 
> Note: Currently, any creating service will be detected as portmap user.
> Probably, this is wrong. But now it depends on program versions "vs_hidden"
> flag.
> 

Yes, I think that nfs4_callback_version4 should also have vs_hidden
set. Currently, it's trying to unregister the service from the
portmapper on shutdown even though it's not registering it. Basically,
any service that sets up its sockets with SVC_SOCK_ANONYMOUS should
also have vs_hidden set on all versions.

-- 
Jeff Layton <jlayton@redhat.com>
