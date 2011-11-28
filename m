Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:48632 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299Ab1K1UjH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Nov 2011 15:39:07 -0500
Date: Mon, 28 Nov 2011 12:39:01 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, john@calva.com, trond.myklebust@netapp.com,
        marek.belisko@gmail.com, awilliam@redhat.com
Subject: Re: [PATCH v3 1/2] sunrpc: make rpc_wait_bit_killable handle
 freeze events
Message-ID: <20111128203901.GG18864@google.com>
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com>
 <1322510488-21189-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322510488-21189-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Nov 28, 2011 at 03:01:27PM -0500, Jeff Layton wrote:
> +#define freezable_schedule()						\
> +({									\
> +	freezer_do_not_count();						\
> +	if (!try_to_freeze())						\
> +		schedule();						\
> +	freezer_count();						\
> +})

I don't think you need try_to_freeze() there when you apply this on
top of pm-freezer branch.  Per-task freezing flag is gone and freezing
condition is completely transient from the POV of each task and the
freezer also doesn't care at all whether a task enters freezer or
becomes unfreezable.

Thanks.

-- 
tejun
