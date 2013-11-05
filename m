Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42393 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153Ab3KEI2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 03:28:17 -0500
Date: Tue, 5 Nov 2013 00:28:11 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Cc: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        chutzpah@gentoo.org, liguangc@cn.ibm.com
Subject: Re: [PATCH] [RFC] vfs: don't revalidate dentries that serve as
 mountpoints
Message-ID: <20131105082811.GA7774@infradead.org>
References: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
 <CADT32eJ_cqej0wnjKOZk1x0UtRqoNy201hFt8hQLLShjcbp3Dg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CADT32eJ_cqej0wnjKOZk1x0UtRqoNy201hFt8hQLLShjcbp3Dg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 09:00:23PM -0600, Shirish Pargaonkar wrote:
> For a similar issue in cifs vfs (samba bugzilla 8950), I was going to try
> unset the bit DCACHE_OP_REVALIDATE of d_flags of the
> dentry.  Would something like work for the mountpoint dentry?

The DCACHE_OP_REVALIDATE are just caches of the available dentry
operations, please don't manipulate those flags on their own.

