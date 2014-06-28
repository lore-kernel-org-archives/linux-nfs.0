Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36291 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaF1LGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2014 07:06:44 -0400
Date: Sat, 28 Jun 2014 04:06:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 010/117] nfsd: Avoid taking state_lock while holding
 inode lock in nfsd_break_one_deleg
Message-ID: <20140628110642.GC10848@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-11-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-11-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static void nfsd4_do_callback_rpc(struct work_struct *w)

nfsd4_run_cb_null?

> +static void nfsd4_do_cb_recall(struct work_struct *w)

nfsd4_run_cb_recall?


Not entirely sure about the name, but I think they should be:

 a) consistent between the two
 b) have somewhat sensible name for the null/probe one

Otherwise looks good to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>
