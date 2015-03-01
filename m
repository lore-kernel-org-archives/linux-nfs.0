Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f169.google.com ([209.85.220.169]:47786 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbbCAP4v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 10:56:51 -0500
Received: by mail-vc0-f169.google.com with SMTP id im6so1599052vcb.0
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2015 07:56:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211123448.GA30174@infradead.org>
References: <20150210154306.GF28949@fieldses.org>
	<20150211123448.GA30174@infradead.org>
Date: Sun, 1 Mar 2015 10:56:50 -0500
Message-ID: <CAHQdGtS7A79fK_voy5D+Fpoki_WNtkP+t5-ox_VuzXOOtYbeoQ@mail.gmail.com>
Subject: Re: hang on xfstests generic/074
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 7:34 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Feb 10, 2015 at 10:43:06AM -0500, J. Bruce Fields wrote:
>> I finally got around to running xfstests as part of my regular testing
>> and ran across a reproduceable hang on generic/074:
>
> Yes, I reported this about half a year ago.  It was caused (or at least
> unhidden) by commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e ("SUNRPC:
> Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT"). Reverting
> that commit fixes the issue for me.
>

Can you please recheck with the new 'devel' branch on
git://git.linux-nfs.org/projects/trondmy/linux-nfs.git ? That fixes
the test for me.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
