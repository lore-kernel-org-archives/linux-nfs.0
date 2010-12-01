Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36904 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753690Ab0LAWZp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 17:25:45 -0500
In-Reply-To: <20101201141351.8609140b.akpm@linux-foundation.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
 <1291229669.6609.24.camel@heimdal.trondhjem.org> <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
 <1291234251.6609.39.camel@heimdal.trondhjem.org> <20101201123341.d12ef362.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1012011258220.18662@tigran.mtv.corp.google.com>
 <alpine.LSU.2.00.1012011311590.18920@tigran.mtv.corp.google.com>
 <20101201133831.ea6ba10a.akpm@linux-foundation.org> <1291240272.6609.50.camel@heimdal.trondhjem.org>
 <20101201141351.8609140b.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 14:24:42 -0800
Message-ID: <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 2:13 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 01 Dec 2010 16:51:12 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>
>> On Wed, 2010-12-01 at 13:38 -0800, Andrew Morton wrote:
>> > Probably on most call paths we'll be OK - if a process is in the middle
>> > of a file truncate, holdin a file* ref which holds an inode ref then
>> > nobody will be unmounting that fs and hence nobody will be unloading
>> > that module.
>> >
>> > However on the random_code->alloc_page->vmscan->releasepage path, none
>> > of that applies.
>>
>> Just out of interest, what ensures that the mapping is still around for
>> the 'spin_unlock_irq(&mapping->tree_lock);' in __remove_mapping()?
>
> Nothing, afacit.

No, we're good.

Module unload has to go through a "stop_machine()" cycle, and that in
turn requires an idle period for everything. And just a preemption
reschedule isn't enough for that.

So what is sufficient is that

 - we had the page locked and on the mapping

   This implies that we had an inode reference to the module, and the
page lock means that the inode reference cannot go away (because it
will involve invalidate-pages etc)

 - we're not sleeping after __remove_mapping, so unload can't happen afterwards.

A _lot_ of the module races depend on that latter thing. We have
almost no cases that are strictly about actual reference counts etc.

                Linus
