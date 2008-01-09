From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Wed, 9 Jan 2008 13:05:54 -0500
Message-ID: <20080109130554.550ccde5@tleilax.poochiereds.net>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
	<1199820798-5289-2-git-send-email-jlayton@redhat.com>
	<1199820798-5289-3-git-send-email-jlayton@redhat.com>
	<1199820798-5289-4-git-send-email-jlayton@redhat.com>
	<20080109173542.GA30523@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: akpm@linux-foundation.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138AbYAISGS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 13:06:18 -0500
In-Reply-To: <20080109173542.GA30523@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Jan 2008 17:35:42 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> I don't think we'll need lockd_start_done anymore after the kthread
> conversion.  When kthread_run returns the thread it created is
> guaranteed to have run until it scheduled away.
> 

Makes sense. My only concern is that we make sure this is behavior we
can count on in the future and not just an artifact of the current
kthread implementation. If that's the case, then I'll plan to remove it
on the next respin.

-- 
Jeff Layton <jlayton@redhat.com>
