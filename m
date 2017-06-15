Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:37542 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdFOIPE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 04:15:04 -0400
Date: Thu, 15 Jun 2017 01:15:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
Message-ID: <20170615081502.GA10599@infradead.org>
References: <20170614170653.58083-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170614170653.58083-1-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 01:06:53PM -0400, Olga Kornievskaia wrote:
> This is a proposal to allow 64bit count to copy and return as
> a result of a copy_file_range. No attempt was made to share code
> with the 32bit function because 32bit interface should probably
> get depreciated.
> 
> Why use 64bit? Current uses of 32bit are by clone_file_range()
> which could use 64bit count and NFS copy_file_range also supports
> 64bit count value.

Please provide a very good use case that actually matters to a large
portion of the Linux users.

> Also with this proposal off-the-bet allow the userland to copy
> between different mount points.

Totally different issue that we've discussed N times.  Trying to sneak
it in behind peoples backs isn't going to improve the situation in any way.
