Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:55740 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751099AbeFDVbo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 17:31:44 -0400
Date: Mon, 4 Jun 2018 17:31:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4 v2] NFS: slight optimization for walking list for
 delegations
Message-ID: <20180604173141.0a154b80@gandalf.local.home>
In-Reply-To: <871sdsv1o5.fsf@notabene.neil.brown.name>
References: <152506256513.7246.13171564155614823841.stgit@noble>
        <152506269054.7246.3941740801391514623.stgit@noble>
        <20180430111741.561df374@gandalf.local.home>
        <871sdsv1o5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 May 2018 15:23:22 +1000
NeilBrown <neilb@suse.com> wrote:

> There are 3 places where we walk the list of delegations
> for an nfs_client.
> In each case there are two nested loops, one for nfs_servers
> and one for nfs_delegations.
> 
> When we find an interesting delegation we try to get an active
> reference to the server.  If that fails, it is pointless to
> continue to look at the other delegation for the server as
> we will never be able to get an active reference.
> So instead of continuing in the inner loop, break out
> and continue in the outer loop.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> This time with a Signed-off-by - sorry.
> I took the opportunity to follow Steven's suggestion
> of adding a comment to the new 'break' statements.
> 

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve
