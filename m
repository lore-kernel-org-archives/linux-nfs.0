Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C52E0C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:19:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 82ECA208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:19:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82ECA208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726273AbeK1ITC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 03:19:02 -0500
Received: from fieldses.org ([173.255.197.46]:43510 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726038AbeK1ITC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 03:19:02 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7988949A; Tue, 27 Nov 2018 16:19:49 -0500 (EST)
Date:   Tue, 27 Nov 2018 16:19:49 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 1/4] nfsd: fix a warning in __cld_pipe_upcall()
Message-ID: <20181127211949.GC12810@fieldses.org>
References: <20181106183511.17836-1-smayhew@redhat.com>
 <20181106183511.17836-2-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106183511.17836-2-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This looks fine, applying now for 4.21.--b.

On Tue, Nov 06, 2018 at 01:35:08PM -0500, Scott Mayhew wrote:
> __cld_pipe_upcall() emits a "do not call blocking ops when
> !TASK_RUNNING" warning due to the dput() call in rpc_queue_upcall().
> Fix it by using a completion instead of hand coding the wait.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 9c247fa1e959..5188f9f70c78 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -662,7 +662,7 @@ struct cld_net {
>  struct cld_upcall {
>  	struct list_head	 cu_list;
>  	struct cld_net		*cu_net;
> -	struct task_struct	*cu_task;
> +	struct completion	 cu_done;
>  	struct cld_msg		 cu_msg;
>  };
>  
> @@ -671,23 +671,18 @@ __cld_pipe_upcall(struct rpc_pipe *pipe, struct cld_msg *cmsg)
>  {
>  	int ret;
>  	struct rpc_pipe_msg msg;
> +	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall, cu_msg);
>  
>  	memset(&msg, 0, sizeof(msg));
>  	msg.data = cmsg;
>  	msg.len = sizeof(*cmsg);
>  
> -	/*
> -	 * Set task state before we queue the upcall. That prevents
> -	 * wake_up_process in the downcall from racing with schedule.
> -	 */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
>  	ret = rpc_queue_upcall(pipe, &msg);
>  	if (ret < 0) {
> -		set_current_state(TASK_RUNNING);
>  		goto out;
>  	}
>  
> -	schedule();
> +	wait_for_completion(&cup->cu_done);
>  
>  	if (msg.errno < 0)
>  		ret = msg.errno;
> @@ -754,7 +749,7 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
>  		return -EFAULT;
>  
> -	wake_up_process(cup->cu_task);
> +	complete(&cup->cu_done);
>  	return mlen;
>  }
>  
> @@ -769,7 +764,7 @@ cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
>  	if (msg->errno >= 0)
>  		return;
>  
> -	wake_up_process(cup->cu_task);
> +	complete(&cup->cu_done);
>  }
>  
>  static const struct rpc_pipe_ops cld_upcall_ops = {
> @@ -900,7 +895,7 @@ alloc_cld_upcall(struct cld_net *cn)
>  			goto restart_search;
>  		}
>  	}
> -	new->cu_task = current;
> +	init_completion(&new->cu_done);
>  	new->cu_msg.cm_vers = CLD_UPCALL_VERSION;
>  	put_unaligned(cn->cn_xid++, &new->cu_msg.cm_xid);
>  	new->cu_net = cn;
> -- 
> 2.17.1
