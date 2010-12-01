Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab0LANOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 08:14:40 -0500
Message-ID: <4CF64A34.7070100@redhat.com>
Date: Wed, 01 Dec 2010 08:14:28 -0500
From: Rik van Riel <riel@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: lock the readdir page while it is in use
References: <1291175234-23824-1-git-send-email-Trond.Myklebust@netapp.com>	 <AANLkTimg+4EYfYnKqNsoOpvCcDs+Pb=FB+arb4NvFpx_@mail.gmail.com>	 <1291175234-23824-2-git-send-email-Trond.Myklebust@netapp.com>	 <1291175234-23824-3-git-send-email-Trond.Myklebust@netapp.com>	 <AANLkTin8FSeM8cQ8BWYWjiyGy33EwzpMfFwauK+4j0uT@mail.gmail.com> <1291177753.7694.17.camel@heimdal.trondhjem.org>
In-Reply-To: <1291177753.7694.17.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/30/2010 11:29 PM, Trond Myklebust wrote:

> I'm not worried about other readdir calls invalidating the page. My
> concern is rather about the VM memory reclaimers ejecting the page from
> the page cache, and calling nfs_readdir_clear_array while we're
> referencing the page.

Wait, if nfs_readdir_clear_array can clear the page while
somebody else has a refcount to it, what good is the
refcount?

Why is your .releasepage modifying the data on the page,
instead of just the metadata in the struct page?

-- 
All rights reversed
