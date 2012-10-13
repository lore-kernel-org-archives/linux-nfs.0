Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51180 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2JMC1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:27:19 -0400
Message-ID: <5078D17C.9090002@panasas.com>
Date: Fri, 12 Oct 2012 19:27:08 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
In-Reply-To: <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2012 04:52 PM, Linus Torvalds wrote:
> Guys, check this report from Larry out.
> 
> Also, why the *HELL* is that a BUG_ON() in the first place? Who was
> the less-than-gifted person who decided "if this thing can happen,
> let's just kill the whole machine"?
> 

Something is trivially weird

fs/lockd/clntxdr.c:226 is in this static function:
	encode_nlm_stat()

encode_nlm_stat() is called in two places
	static void nlm_xdr_enc_res(...)
  and
	static void nlm_xdr_enc_testres(...)

But these two are not called anywhere. In-fact a Kernel wide grep
returns a single occurrence of both

I suspect the BUG_ON() belongs else where.
Perhaps we should add __func__ to the BUG_ON macro exactly for times
that source and Kernel get out of sync.

Puzzled
Boaz
