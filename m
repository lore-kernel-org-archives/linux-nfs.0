Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51931 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845Ab2JMCji (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:39:38 -0400
Message-ID: <5078D45A.3090801@panasas.com>
Date: Fri, 12 Oct 2012 19:39:22 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
References: <20121012211701.GA8301@bitmover.com>  <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>  <5078D17C.9090002@panasas.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2012 07:32 PM, Myklebust, Trond wrote:
> On Fri, 2012-10-12 at 19:27 -0700, Boaz Harrosh wrote:
>> On 10/12/2012 04:52 PM, Linus Torvalds wrote:
>>> Guys, check this report from Larry out.
>>>
>>> Also, why the *HELL* is that a BUG_ON() in the first place? Who was
>>> the less-than-gifted person who decided "if this thing can happen,
>>> let's just kill the whole machine"?
>>>
>>
>> Something is trivially weird
>>
>> fs/lockd/clntxdr.c:226 is in this static function:
>> 	encode_nlm_stat()
>>
>> encode_nlm_stat() is called in two places
>> 	static void nlm_xdr_enc_res(...)
>>   and
>> 	static void nlm_xdr_enc_testres(...)
>>
>> But these two are not called anywhere. In-fact a Kernel wide grep
>> returns a single occurrence of both
> 
> They are used in the nlm_procedures[] array as TEST_RES, LOCK_RES,
> CANCEL_RES, UNLOCK_RES and GRANTED_RES xdr encoding procedures.
> 

Ha, sorry that was impossible to find. OK I'll have a look

Thanks
Boaz
