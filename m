From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Wed, 9 Jan 2008 17:35:42 +0000
Message-ID: <20080109173542.GA30523@infradead.org>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com> <1199820798-5289-2-git-send-email-jlayton@redhat.com> <1199820798-5289-3-git-send-email-jlayton@redhat.com> <1199820798-5289-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41450 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188AbYAIRgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 12:36:06 -0500
In-Reply-To: <1199820798-5289-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 02:33:15PM -0500, Jeff Layton wrote:
> lockd_start_done is a global var that can be reused if lockd is
> restarted, but it's never reinitialized. On all but the first use,
> wait_for_completion isn't actually waiting on it since it has
> already completed once.

I don't think we'll need lockd_start_done anymore after the kthread
conversion.  When kthread_run returns the thread it created is
guaranteed to have run until it scheduled away.

