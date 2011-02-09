Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34147 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab1BIFBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 00:01:19 -0500
Date: Wed, 9 Feb 2011 00:01:18 -0500
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Message-ID: <20110209050118.GA2485@infradead.org>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
 <1297227351-15365-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1297227351-15365-2-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> +static
> +void nfsd_break_deleg_cb(struct file_lock *fl)

Very weird formatting.  Please make it either

static void nfsd_break_deleg_cb(struct file_lock *fl)

or

static void
nfsd_break_deleg_cb(struct file_lock *fl)

but never just put the static on a line of it's own.

