Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47634 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934912AbcIFSOz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 14:14:55 -0400
Date: Tue, 6 Sep 2016 14:14:53 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Fix callback channel handling of referring triples
Message-ID: <20160906181453.GA29563@fieldses.org>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 28, 2016 at 06:21:00PM -0400, Trond Myklebust wrote:
> RFC5661 has a mechanism for ensuring that the forward channel and backward
> channel do not race. The Linux client implements this mechanism, but in
> a manner that is racy, making it rather pointless, and buggy (Oops!).
> 
> This patch series fixes the most egregious issues around delegations and
> layouts by ensuring that we wait for completion of the actual setup of
> the delegation or layout that could be subject to recall.

Out of curiosity--so do we know if there are servers out there using
it at this point?

--b.

> 
> Trond Myklebust (5):
>   NFSv4.1: Fix Oopsable condition in server callback races
>   NFSv4.1: Delay callback processing when there are referring triples
>   NFSv4.1: Defer bumping the slot sequence number until we free the slot
>   NFSv4.1: Close callback races for OPEN, LAYOUTGET and LAYOUTRETURN
>   NFSv4.1: Remove obsolete and incorrrect assignment in
>     nfs4_callback_sequence
> 
>  fs/nfs/callback_proc.c |  8 ++---
>  fs/nfs/nfs4proc.c      | 89 +++++++++++++++++++++++++++++++++++++++++---------
>  fs/nfs/nfs4session.c   | 53 ++++++++++++++++++++++++++++++
>  fs/nfs/nfs4session.h   |  7 +++-
>  4 files changed, 135 insertions(+), 22 deletions(-)
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
