From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Mon, 7 Apr 2008 12:45:01 -0400
Message-ID: <20080407164500.GA17728@infradead.org>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com> <1207575514-6703-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51603 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbYDGQpM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2008 12:45:12 -0400
In-Reply-To: <1207575514-6703-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> The global task and serv pointers for lockd are normally protected by
> the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> this occurs, these variables are cleared without any locking.

Shouldn't we get rid of the case where it exits abnormally instead?

