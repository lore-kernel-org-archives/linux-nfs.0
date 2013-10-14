Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41267 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab3JNOPo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 10:15:44 -0400
Date: Mon, 14 Oct 2013 07:15:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map
 super_blocks to devid major identifiers
Message-ID: <20131014141535.GA32062@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
 <20131011195608.GA18634@infradead.org>
 <525A399C.5040405@primarydata.com>
 <20131013110820.GA31153@infradead.org>
 <525A95AE.7060008@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525A95AE.7060008@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 13, 2013 at 03:44:30PM +0300, Benny Halevy wrote:
> As far as I can see, exofs doesn't actually doing that.
> Currently exofs_fill_super sets s_dev = 0;
> Boaz, did I miss anything?

Just removing that line should fix it, mount_nodev already takes care of
getting a proper s_dev through set_anon_super.  It'll also need to
switch .kill_sb to kill_anon_super just like the other filesystems using
mount_nodev.

