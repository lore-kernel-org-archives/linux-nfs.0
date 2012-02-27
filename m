Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:21209 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2B0SHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 13:07:40 -0500
Message-ID: <4F4BC652.6030300@parallels.com>
Date: Mon, 27 Feb 2012 22:07:14 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3 1/4] SUNRPC: release per-net clients lock before calling
 PipeFS dentries creation
References: <20120227180509.1089.29555.stgit@localhost6.localdomain6> <20120227180529.1089.29305.stgit@localhost6.localdomain6>
In-Reply-To: <20120227180529.1089.29305.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

27.02.2012 22:05, Stanislav Kinsbursky пишет:
> v3:
> 1) Lookup for client is performed from the beginning of the list on each PipeFS
> event handling operation.
>
> Lockdep is sad otherwise, because inode mutex is taken on PipeFS dentry
> creation, which can be called on mount notification, where this per-net client
> lock is taken on clients list walk.
>
> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> ---
>   net/sunrpc/clnt.c |   26 +++++++++++++++++++++-----
>   1 files changed, 21 insertions(+), 5 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index bb7ed2f3..48f3d15 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -50,7 +50,7 @@
>   			__func__, t->tk_status)
>
>   /*
> - * All RPC clients are linked into this list
> + * All RPC clients are linked into this list Client Cto hand;le ustatus is checke
>    */
>
>   static DECLARE_WAIT_QUEUE_HEAD(destroy_wait);

Sorry for this hunk.

-- 
Best regards,
Stanislav Kinsbursky
