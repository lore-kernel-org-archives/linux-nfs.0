Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48914 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab0LAXVe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 18:21:34 -0500
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
In-Reply-To: <1291243633.6609.59.camel@heimdal.trondhjem.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	 <20101201150428.GA2879@elliptictech.com>
	 <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	 <1291229669.6609.24.camel@heimdal.trondhjem.org>
	 <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
	 <1291234251.6609.39.camel@heimdal.trondhjem.org>
	 <20101201123341.d12ef362.akpm@linux-foundation.org>
	 <alpine.LSU.2.00.1012011258220.18662@tigran.mtv.corp.google.com>
	 <alpine.LSU.2.00.1012011311590.18920@tigran.mtv.corp.google.com>
	 <20101201133831.ea6ba10a.akpm@linux-foundation.org>
	 <1291240272.6609.50.camel@heimdal.trondhjem.org>
	 <20101201141351.8609140b.akpm@linux-foundation.org>
	 <AANLkTimgZPET+T16Qpj_KnpCu==97g-8+_y5dtjNOrxG@mail.gmail.com>
	 <20101201143856.51f4f9d9.akpm@linux-foundation.org>
	 <1291243633.6609.59.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 18:21:16 -0500
Message-ID: <1291245676.6609.62.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 17:47 -0500, Trond Myklebust wrote:
> However, Linus' explanation appears to answer one of Hugh's objections:
> we can apparently use a preempt-disable() in order to ensure that the
> module containing the mapping->a_ops is not unloaded until after the
> ->freepage() call is complete.
> 
> That would imply that ->freepage() cannot sleep, but I don't think that
> is too nasty a restriction.

Revised patch would be as follows...

----------------------------------------------------------------------------------------
