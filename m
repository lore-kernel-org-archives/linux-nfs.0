Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab0LARCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 12:02:22 -0500
Message-ID: <4CF67F8E.6050308@redhat.com>
Date: Wed, 01 Dec 2010 12:02:06 -0500
From: Rik van Riel <riel@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com> <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <4CF67955.2050808@redhat.com> <AANLkTinwrhUOQ0LnavQY6+TQS_TqnRS0q-XXykZ8ap5G@mail.gmail.com>
In-Reply-To: <AANLkTinwrhUOQ0LnavQY6+TQS_TqnRS0q-XXykZ8ap5G@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/01/2010 11:47 AM, Linus Torvalds wrote:
> On Wed, Dec 1, 2010 at 8:35 AM, Rik van Riel<riel@redhat.com>  wrote:
>>
>> Surely somebody can have just looked up the page and
>> gotten a reference count, right before your ->freepage
>> call is invoked?
>
> No.
>
> The removal from the page cache is atomic, even in the presence of the
> lockless lookup.
>
> The page cache lookup does a "get_page_unless_zero()" on the count, so
> when __remove_mapping() has removed the page using
> "page_freeze_refs()", it's really gone, and cannot be looked up.

Doh, you're right.  I forgot to look at all the stuff that
__remove_mapping does nowadays and remembered some very old
code from vmscan.c instead.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed
