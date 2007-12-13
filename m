From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/6] SUNRPC: Break up __svc_create_thread and make
	svc_create_kthread
Date: Thu, 13 Dec 2007 21:06:44 +0000
Message-ID: <20071213210643.GA28117@infradead.org>
References: <1197578428-26815-1-git-send-email-jlayton@redhat.com> <1197578428-26815-2-git-send-email-jlayton@redhat.com> <1197578428-26815-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57835 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765729AbXLMVGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2007 16:06:45 -0500
In-Reply-To: <1197578428-26815-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2007 at 03:40:24PM -0500, Jeff Layton wrote:
> Move the initialization that happens prior to thread creation to a new
> function (svc_prepare_thread) so that we can call it from a new thread
> creation routine. Add a new function svc_create_kthread that spawns svc
> threads using kthread API.
> 
> We should be able to eventually convert all of the callers to the
> kthread API, at which point we can drop __svc_create_thread.

> +static struct svc_rqst *
> +svc_prepare_thread(svc_thread_fn func, struct svc_serv *serv,
> +		   struct svc_pool *pool)

Could you just export this helper? I'd rather have callers have full
control over how they create their threads and call into a helper to
initialize the sunrpc state.

