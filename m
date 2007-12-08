From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NLM: Add lockd reference counting and clean up lockd
	startup and shutdown
Date: Sat, 8 Dec 2007 14:07:47 +0000
Message-ID: <20071208140747.GA11675@infradead.org>
References: <1197118932-4512-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55068 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbXLHOHt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Dec 2007 09:07:49 -0500
In-Reply-To: <1197118932-4512-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	mutex_lock(&nlmsvc_mutex);
> +	while (atomic_read(&nlmsvc_ref) != 0) {

might be better to do the refcounting outside the thread and use the
kthread api, which is something we still need to do for lockd anyway.

