Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:45828 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbaF1MSD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2014 08:18:03 -0400
Received: by mail-qa0-f53.google.com with SMTP id j15so4894189qaq.40
        for <linux-nfs@vger.kernel.org>; Sat, 28 Jun 2014 05:18:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 28 Jun 2014 08:18:00 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 010/117] nfsd: Avoid taking state_lock while holding
 inode lock in nfsd_break_one_deleg
Message-ID: <20140628081800.03af4192@tlielax.poochiereds.net>
In-Reply-To: <20140628110642.GC10848@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<1403810017-16062-11-git-send-email-jlayton@primarydata.com>
	<20140628110642.GC10848@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 28 Jun 2014 04:06:42 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +static void nfsd4_do_callback_rpc(struct work_struct *w)
> 
> nfsd4_run_cb_null?
> 
> > +static void nfsd4_do_cb_recall(struct work_struct *w)
> 
> nfsd4_run_cb_recall?
> 
> 
> Not entirely sure about the name, but I think they should be:
> 
>  a) consistent between the two
>  b) have somewhat sensible name for the null/probe one
> 
> Otherwise looks good to me,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Those names sound fine to me. I'll change the patch to use them instead.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
