Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33740 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932162AbcLWHTa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2016 02:19:30 -0500
Date: Thu, 22 Dec 2016 23:19:28 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: pass an integer for stable type to
 nfsd_vfs_write
Message-ID: <20161223071928.GA19287@infradead.org>
References: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0df957d0-3405-b12f-0d39-210a0edd6f60@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 23, 2016 at 09:32:15AM +0800, Kinglong Mee wrote:
> Commit fae5096ad217 "nfsd: assume writeable exportabled filesystems have f_sync"
> have remove the setting of stable.

Btw, that commit really should check for fsync support at export
time then, never underestimate how broken file systems could be.
