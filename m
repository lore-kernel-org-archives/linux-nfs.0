From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Wed, 06 Feb 2008 13:52:34 -0500
Message-ID: <1202323955.8549.24.camel@heimdal.trondhjem.org>
References: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
	 <1202322103-13716-2-git-send-email-jlayton@redhat.com>
	 <1202322103-13716-3-git-send-email-jlayton@redhat.com>
	 <1202322991.8549.7.camel@heimdal.trondhjem.org>
	 <20080206134702.14c9d4f0@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:50498 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbYBFSwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:52:47 -0500
In-Reply-To: <20080206134702.14c9d4f0-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-06 at 13:47 -0500, Jeff Layton wrote:
> There's no guarantee that kthread_stop() won't wake up lockd before
> schedule_timeout() gets called, but after the last check for
> kthread_should_stop().

Doesn't the BKL pretty much eliminate this race? (assuming you transform
that call to 'if (!kthread_should_stop()) schedule_timeout();')

Trond

