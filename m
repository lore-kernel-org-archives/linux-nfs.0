Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975Ab0HAT4I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 15:56:08 -0400
Subject: Re: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 && !CONFIG_NFS_V3
References: <1280519035.12852.32.camel@heimdal.trondhjem.org> <20100801064415.GA10523@elte.hu> <AANLkTim=6q1FC8YZvmi2Cju_6+00mHHkNPpCLHB8e3=h@mail.gmail.com> <1280684100.4430.8.camel@heimdal.trondhjem.org> <20100801194502.GA3801@infradead.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Content-Type: text/plain;
	charset="us-ascii"
In-Reply-To: <20100801194502.GA3801@infradead.org>
Message-ID: <E70766A7-AFAB-414A-8FB3-F36275A81CAB@netapp.com>
Date: Sun, 1 Aug 2010 15:56:16 -0400
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
        "Ingo Molnar" <mingo@elte.hu>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, "Randy Dunlap" <rdunlap@xenotime.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug 1, 2010, at 15:45, Christoph Hellwig <hch@infradead.org> wrote:

> Btw, is there a reason to allow not building NFSv3?  If at all
> building without v2 support would be more useful.
> 
I am planning to separate nfsv2, nfsv3 and nfsv4 into loadable submodules at some point in the not-too-distant future. That seems like a better solution than these CONFIG suboptions that keep tripping us up.

Cheers
    Trond