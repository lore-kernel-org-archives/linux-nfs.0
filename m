Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:37861 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753101Ab2JMCaD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:30:03 -0400
Date: Fri, 12 Oct 2012 19:30:00 -0700
From: Larry McVoy <lm@bitmover.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121013023000.GI23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <5078D17C.9090002@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5078D17C.9090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In BitKeeper, we wacked perror() to print out file, line.  Saved us
a ton of debugging.  Oh, and bk-version as well.  That helps.

On Fri, Oct 12, 2012 at 07:27:08PM -0700, Boaz Harrosh wrote:
> On 10/12/2012 04:52 PM, Linus Torvalds wrote:
> > Guys, check this report from Larry out.
> > 
> > Also, why the *HELL* is that a BUG_ON() in the first place? Who was
> > the less-than-gifted person who decided "if this thing can happen,
> > let's just kill the whole machine"?
> > 
> 
> Something is trivially weird
> 
> fs/lockd/clntxdr.c:226 is in this static function:
> 	encode_nlm_stat()
> 
> encode_nlm_stat() is called in two places
> 	static void nlm_xdr_enc_res(...)
>   and
> 	static void nlm_xdr_enc_testres(...)
> 
> But these two are not called anywhere. In-fact a Kernel wide grep
> returns a single occurrence of both
> 
> I suspect the BUG_ON() belongs else where.
> Perhaps we should add __func__ to the BUG_ON macro exactly for times
> that source and Kernel get out of sync.
> 
> Puzzled
> Boaz

-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
