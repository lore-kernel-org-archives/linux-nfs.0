Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:37398 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbCAP66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 10:58:58 -0500
Received: by mail-vc0-f171.google.com with SMTP id la4so1612120vcb.2
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2015 07:58:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtS7A79fK_voy5D+Fpoki_WNtkP+t5-ox_VuzXOOtYbeoQ@mail.gmail.com>
References: <20150210154306.GF28949@fieldses.org>
	<20150211123448.GA30174@infradead.org>
	<CAHQdGtS7A79fK_voy5D+Fpoki_WNtkP+t5-ox_VuzXOOtYbeoQ@mail.gmail.com>
Date: Sun, 1 Mar 2015 10:58:57 -0500
Message-ID: <CAHQdGtRy8XYNWyyGnmnGqaw-RaS1KOSSJcPE02a+sTFakLPgPg@mail.gmail.com>
Subject: Re: hang on xfstests generic/074
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 1, 2015 at 10:56 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Feb 11, 2015 at 7:34 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Tue, Feb 10, 2015 at 10:43:06AM -0500, J. Bruce Fields wrote:
>>> I finally got around to running xfstests as part of my regular testing
>>> and ran across a reproduceable hang on generic/074:
>>
>> Yes, I reported this about half a year ago.  It was caused (or at least
>> unhidden) by commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e ("SUNRPC:
>> Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT"). Reverting
>> that commit fixes the issue for me.
>>
>
> Can you please recheck with the new 'devel' branch on
> git://git.linux-nfs.org/projects/trondmy/linux-nfs.git ? That fixes
> the test for me.
>

Oops. Never mind. I was thinking of a different issue, but also with
generic/074.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
