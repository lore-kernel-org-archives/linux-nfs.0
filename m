Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858Ab0LAQfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 11:35:45 -0500
Message-ID: <4CF67955.2050808@redhat.com>
Date: Wed, 01 Dec 2010 11:35:33 -0500
From: Rik van Riel <riel@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com> <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com> <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
In-Reply-To: <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/01/2010 11:17 AM, Linus Torvalds wrote:

> So this is a TOTALLY UNTESTED trivial patch that just adds another
> callback. Does this work? I dunno. But I get the feeling that instead
> of having NFS work around the odd semantics that don't actually match
> what NFS wants, introducing a new callback with much simpler semantics
> would be simpler for everybody, and avoid the need for subtle code.

Surely somebody can have just looked up the page and
gotten a reference count, right before your ->freepage
call is invoked?

CPU A				CPU B

look up page
grab refcount
				->freepage

use contents of page

Am I overlooking something obvious?

-- 
All rights reversed
