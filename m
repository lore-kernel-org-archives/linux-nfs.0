Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC92C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 15:13:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4899C20674
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 15:13:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388457AbfDRPNM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 11:13:12 -0400
Received: from fieldses.org ([173.255.197.46]:41602 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388070AbfDRPNM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 11:13:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 218DA88A; Thu, 18 Apr 2019 11:13:12 -0400 (EDT)
Date:   Thu, 18 Apr 2019 11:13:12 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Message-ID: <20190418151312.GB29274@fieldses.org>
References: <20190418132400.24161-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418132400.24161-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 18, 2019 at 09:24:00AM -0400, Scott Mayhew wrote:
> While trying to track down some issues involving large numbers of
> delegations being recalled/revoked, I caught the server setting
> SEQ4_STATUS_CB_PATH_DOWN while the client was actively responding to
> CB_RECALLs.  It turns out that the client had already done a
> TEST_STATEID and FREE_STATEID for a delegation being recalled by the
> time it received the CB_RECALL.

That's interesting, thanks!

This exception seems awfully narrow, though.

If we get back any NFS-level error at all, then I think the callback
channel is working (am I wrong?) and telling the client to set up a new
one is probably not going to help.  The best we can do is probably just
give up and let the client deal with the ensuing
RECALLABLE_STATE_REVOKED flag.

--b.

> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6a45fb00c5fc..e88e429133a8 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3958,6 +3958,14 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
>  			rpc_delay(task, 2 * HZ);
>  			return 0;
>  		}
> +		/*
> +		 * Race: client may have done a FREE_STATEID before
> +		 * receiving the CB_RECALL.
> +		 */
> +		if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID &&
> +				refcount_read(&dp->dl_stid.sc_count) == 1 &&
> +				list_empty(&dp->dl_recall_lru))
> +			return 1;
>  		/*FALLTHRU*/
>  	default:
>  		return -1;
> -- 
> 2.17.2
