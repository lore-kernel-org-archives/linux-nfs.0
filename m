From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Wed, 9 Jan 2008 18:14:56 +0000
Message-ID: <20080109181456.GA32432@infradead.org>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com> <1199820798-5289-2-git-send-email-jlayton@redhat.com> <1199820798-5289-3-git-send-email-jlayton@redhat.com> <1199820798-5289-4-git-send-email-jlayton@redhat.com> <20080109173542.GA30523@infradead.org> <20080109130554.550ccde5@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:53502 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbYAISPB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 13:15:01 -0500
In-Reply-To: <20080109130554.550ccde5-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 09, 2008 at 01:05:54PM -0500, Jeff Layton wrote:
> Makes sense. My only concern is that we make sure this is behavior we
> can count on in the future and not just an artifact of the current
> kthread implementation. If that's the case, then I'll plan to remove it
> on the next respin.

It's absolutely intentional and one of the reasons why the kthread
infrastructure is so much nicer than plain kthread_create :)

