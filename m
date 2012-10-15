Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40714 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab2JOSVC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 14:21:02 -0400
Message-ID: <507C5400.4030609@panasas.com>
Date: Mon, 15 Oct 2012 11:20:48 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Bruce Fields <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com> <5078D17C.9090002@panasas.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com> <5078D45A.3090801@panasas.com> <20121014194351.GD32420@fieldses.org>
In-Reply-To: <20121014194351.GD32420@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/14/2012 12:43 PM, Bruce Fields wrote:
> On Fri, Oct 12, 2012 at 07:39:22PM -0700, Boaz Harrosh wrote:
>> On 10/12/2012 07:32 PM, Myklebust, Trond wrote:
>>> They are used in the nlm_procedures[] array as TEST_RES, LOCK_RES,
>>> CANCEL_RES, UNLOCK_RES and GRANTED_RES xdr encoding procedures.
>>
>> Ha, sorry that was impossible to find. OK I'll have a look
> 
> Everybody falls into that trap at least once.  Any objections to killing
> those macros and expanding that stuff out?
> 

No objections from me. I did the one file just to understand and
actually I think the code even looks better without them.

But then I realized they are all over, I'm not sure I'll have
time to do it

> --b.
> 

Thanks
Boaz
