Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.17.13]:55539 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569AbaGNOYB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 10:24:01 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, Paul McKenney <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
Date: Mon, 14 Jul 2014 16:23:53 +0200
Message-ID: <6702571.1HVrh55XfQ@wuerfel>
In-Reply-To: <1405303064-9102-2-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com> <1405303064-9102-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday 13 July 2014 21:57:38 Jeff Layton wrote:
> 
> Commit 5b22216e11f7 (nfs: __rcu annotations) added a __rcu annotation to
> the gc_gss_ctx field. I see no rationale for adding that though, as that
> field does not seem to be managed via RCU at all.
> 
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Unfortunately, it's been too long ago for me to remember what led to me
adding it. I also don't see a reason for it in today's code, but I don't
know if the code has changed, if I made a mistake then, or if it's actually
needed for some reason I don't see.

	Arnd
