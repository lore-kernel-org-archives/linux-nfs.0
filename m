Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab2JNTny (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Oct 2012 15:43:54 -0400
Date: Sun, 14 Oct 2012 15:43:51 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121014194351.GD32420@fieldses.org>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <5078D17C.9090002@panasas.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com>
 <5078D45A.3090801@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5078D45A.3090801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 12, 2012 at 07:39:22PM -0700, Boaz Harrosh wrote:
> On 10/12/2012 07:32 PM, Myklebust, Trond wrote:
> > On Fri, 2012-10-12 at 19:27 -0700, Boaz Harrosh wrote:
> >> On 10/12/2012 04:52 PM, Linus Torvalds wrote:
> >>> Guys, check this report from Larry out.
> >>>
> >>> Also, why the *HELL* is that a BUG_ON() in the first place? Who was
> >>> the less-than-gifted person who decided "if this thing can happen,
> >>> let's just kill the whole machine"?
> >>>
> >>
> >> Something is trivially weird
> >>
> >> fs/lockd/clntxdr.c:226 is in this static function:
> >> 	encode_nlm_stat()
> >>
> >> encode_nlm_stat() is called in two places
> >> 	static void nlm_xdr_enc_res(...)
> >>   and
> >> 	static void nlm_xdr_enc_testres(...)
> >>
> >> But these two are not called anywhere. In-fact a Kernel wide grep
> >> returns a single occurrence of both
> > 
> > They are used in the nlm_procedures[] array as TEST_RES, LOCK_RES,
> > CANCEL_RES, UNLOCK_RES and GRANTED_RES xdr encoding procedures.
> 
> Ha, sorry that was impossible to find. OK I'll have a look

Everybody falls into that trap at least once.  Any objections to killing
those macros and expanding that stuff out?

--b.
