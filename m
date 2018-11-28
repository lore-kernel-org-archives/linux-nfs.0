Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B18EFC04EB8
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 11:37:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F4712086B
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 11:37:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F4712086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727841AbeK1Wi3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 17:38:29 -0500
Received: from mail-yb1-f193.google.com ([209.85.219.193]:43708 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727491AbeK1Wi3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 17:38:29 -0500
Received: by mail-yb1-f193.google.com with SMTP id h187-v6so10450970ybg.10
        for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2018 03:37:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=0HhLMdEBbTxDO26usXtQVGyF5x4TUjha7ZofvYd8GOo=;
        b=XMI3ZlC/oAVI8Tu2RvW8vRRjd6JPQM6Xr6LJUVFcUbMO4T65yftNqHFa5yEkoEZEiy
         VYGAA70nmCDDmgMXtphq0dRl9Ann+Y6RV7wO/g6C3YeIKH2uTNzMZlAx1XxIfrTpTL9w
         Ziq+CyU5LAPeZhKh/Tal3Y0zrbNQIJhq5hPpaU2Go0uDD0FN6kgBZJbb7Y5ivYMkfB+O
         sYR7cdfdZfBR8S8TPV3x8L4SlY0QMq1cBHLE5jaRmvKxuMH+Ug1pGJJzmWcGJ0L4gZM2
         ZuQVc6qLY3Y26gdZYWdXTo88TLcZdUO/5nWXoRyrono02eF0IZn/PI/TS6q1sXtf3vQE
         1zsg==
X-Gm-Message-State: AA+aEWah7+RT/y7xNDMR4XKnqO1DVXkPy+aF6mrhUpxRSI+LPhG6Qj1F
        gUFmJvoT7E/tRurdKShDBSuTug==
X-Google-Smtp-Source: AFSGD/V+EcjiwFrJD3tJTIzW9/l+bF3ZfjZrpJyrPDzcynX6KuDoCQZpvFImFnSzuVKN4qwGGVKxeg==
X-Received: by 2002:a5b:7c6:: with SMTP id t6-v6mr23403666ybq.406.1543405027478;
        Wed, 28 Nov 2018 03:37:07 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com. [71.70.156.158])
        by smtp.gmail.com with ESMTPSA id h75sm4713340ywa.50.2018.11.28.03.37.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Nov 2018 03:37:06 -0800 (PST)
Message-ID: <9bba46b3f9b67a3a52c3a1f22caa9cd7cdabfca7.camel@redhat.com>
Subject: Re: [PATCH] locks: fix performance regressions.
From:   Jeff Layton <jlayton@redhat.com>
To:     NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>,
        kernel test robot <rong.a.chen@intel.com>
Cc:     LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
        linux-nfs@vger.kernel.org
Date:   Wed, 28 Nov 2018 06:37:05 -0500
In-Reply-To: <87k1kyowdf.fsf@notabene.neil.brown.name>
References: <20181127060102.GF6163@shao2-debian>
         <20181127174315.GA29963@parsley.fieldses.org>
         <87mupup0ot.fsf@notabene.neil.brown.name>
         <87k1kyowdf.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 (3.30.2-2.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2018-11-28 at 11:53 +1100, NeilBrown wrote:
> The kernel test robot reported two performance regressions
> caused by recent patches.
> Both appear to related to the global spinlock blocked_lock_lock
> being taken more often.
> 
> This patch avoids taking that lock in the cases tested.
> 
> Reported-by: kernel test robot <rong.a.chen@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Hi Jeff,
>  you might like to merge these back into the patches that introduced
>  the problem.
>  Or you might like me to re-send the series with these merged in,
>  in which case, please ask.
> 

Thanks Neil,

This looks great. I'll go ahead and toss this patch on top of the pile
in linux-next for now.

Would you mind resending the series with this patch merged in? I took a
quick stab at squashing it into the earlier patch, but there is some
churn in this area.

Maybe you can also turn that Reported-by: into a Tested-by: in the
changelog afterward?

> And a BIG thank-you to the kernel-test-robot team!!
> 

Absolutely! We love you guys!

> Thanks,
> NeilBrown
> 
>  fs/locks.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index f456cd3d9d50..67519a43e27a 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -444,6 +444,13 @@ static void locks_move_blocks(struct file_lock *new, struct file_lock *fl)
>  {
>  	struct file_lock *f;
>  
> +	/*
> +	 * As ctx->flc_lock is held, new requests cannot be added to
> +	 * ->fl_blocked_requests, so we don't need a lock to check if it
> +	 * is empty.
> +	 */
> +	if (list_empty(&fl->fl_blocked_requests))
> +		return;
>  	spin_lock(&blocked_lock_lock);
>  	list_splice_init(&fl->fl_blocked_requests, &new->fl_blocked_requests);
>  	list_for_each_entry(f, &fl->fl_blocked_requests, fl_blocked_member)
> @@ -749,6 +756,20 @@ int locks_delete_block(struct file_lock *waiter)
>  {
>  	int status = -ENOENT;
>  
> +	/*
> +	 * If fl_blocker is NULL, it won't be set again as this thread
> +	 * "owns" the lock and is the only one that might try to claim
> +	 * the lock.  So it is safe to test fl_blocker locklessly.
> +	 * Also if fl_blocker is NULL, this waiter is not listed on
> +	 * fl_blocked_requests for some lock, so no other request can
> +	 * be added to the list of fl_blocked_requests for this
> +	 * request.  So if fl_blocker is NULL, it is safe to
> +	 * locklessly check if fl_blocked_requests is empty.  If both
> +	 * of these checks succeed, there is no need to take the lock.
> +	 */
> +	if (waiter->fl_blocker == NULL &&
> +	    list_empty(&waiter->fl_blocked_requests))
> +		return status;
>  	spin_lock(&blocked_lock_lock);
>  	if (waiter->fl_blocker)
>  		status = 0;

-- 
Jeff Layton <jlayton@redhat.com>

