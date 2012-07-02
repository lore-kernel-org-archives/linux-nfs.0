Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:38139 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932871Ab2GBVvh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 17:51:37 -0400
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ resulting in hang (BAD_STATEID)
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1341265720.8197.56.camel@lade.trondhjem.org>
Date: Mon, 2 Jul 2012 17:50:31 -0400
Cc: "Linux;NFS Mailing List" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <E77A07D9-EFA1-4C52-B0A9-3E81401341E5@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com> <2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com> <CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com> <2F725B49-A089-41E9-BBC9-11B889A62C9D@oracle.com> <1341263584.8197.53.camel@lade.trondhjem.org> <6C5408EB-668A-43C9-B3FE-9D66427B5BE0@oracle.com> <1341265720.8197.56.camel@lade.trondhjem.org>
To: "Charles 'Boyo" <charlesboyo@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 2, 2012, at 5:48 PM, Myklebust, Trond wrote:

> On Mon, 2012-07-02 at 17:19 -0400, Chuck Lever wrote:
>> On Jul 2, 2012, at 5:13 PM, Myklebust, Trond wrote:
>> 
>>> On Mon, 2012-07-02 at 16:35 -0400, Chuck Lever wrote:
>>>> On Jul 2, 2012, at 4:22 PM, Charles 'Boyo wrote:
>>>> 
>>>>> On Mon, Jul 2, 2012 at 3:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>> 
>>>>>> Usually we see this behavior because of a race between an OPEN with delegation and a delegation recall.  In this case, however, the client is actively returning a READ
>>>>>> delegation, then proceeding to use it anyway.  I don't see the server's recall callback, though, and there are other indications that this trace is not complete. So it's hard
>>>>>> to be 100% confident.
>>>>>> 
>>>>> The trace is not complete, it includes just enough information to
>>>>> explain the problem.
>>>>> However I can confirm the service did not send a recall callback, the
>>>>> client returned the delegation of its own "free will".
>>>> 
>>>> The callback would come on a separate TCP connection.  I can't think of a reason that a client would return a delegation by itself and then subsequently start to use it.
>>> 
>>> I can: there are a number of servers out there that violate the spec by
>>> returning a delegation as part of an OPEN(CLAIM_DELEGATE_CUR). Usually
>>> those broken servers will send the exact same stateid as the delegation
>>> that is being returned.
>> 
>> The OPEN in frame 7 is a CLAIM_NULL OPEN, isn't it?
> 
> Yes. Is there a preamble to that, or did the client really try to
> delegreturn immediately upon receiving a delegation?

Charles, we would like to see an un-redacted trace, if you have one.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




