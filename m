Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59977 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105Ab0LAQp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 11:45:56 -0500
Message-ID: <4CF67BBE.8050303@panasas.com>
Date: Wed, 01 Dec 2010 18:45:50 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Rik van Riel <riel@redhat.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com> <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com> <4CF67955.2050808@redhat.com>
In-Reply-To: <4CF67955.2050808@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-01 18:35, Rik van Riel wrote:
> On 12/01/2010 11:17 AM, Linus Torvalds wrote:
> 
>> So this is a TOTALLY UNTESTED trivial patch that just adds another
>> callback. Does this work? I dunno. But I get the feeling that instead
>> of having NFS work around the odd semantics that don't actually match
>> what NFS wants, introducing a new callback with much simpler semantics
>> would be simpler for everybody, and avoid the need for subtle code.
> 
> Surely somebody can have just looked up the page and
> gotten a reference count, right before your ->freepage
> call is invoked?
> 
> CPU A				CPU B
> 
> look up page
> grab refcount
> 				->freepage
> 
> use contents of page
> 
> Am I overlooking something obvious?
> 

The page is not cached any more at this point therefore
looking it up won't find it.

Benny
