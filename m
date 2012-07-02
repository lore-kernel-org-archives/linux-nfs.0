Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:54981 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932314Ab2GBVuk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 17:50:40 -0400
Received: by gglu4 with SMTP id u4so4617211ggl.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jul 2012 14:50:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6C5408EB-668A-43C9-B3FE-9D66427B5BE0@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
	<2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com>
	<CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com>
	<2F725B49-A089-41E9-BBC9-11B889A62C9D@oracle.com>
	<1341263584.8197.53.camel@lade.trondhjem.org>
	<6C5408EB-668A-43C9-B3FE-9D66427B5BE0@oracle.com>
Date: Mon, 2 Jul 2012 22:50:38 +0100
Message-ID: <CAPD_G3KojVhnjtfjN0poJvpV0i+6JZeK54rm5Swm3MDKEXQ=Zw@mail.gmail.com>
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ
 resulting in hang (BAD_STATEID)
From: "Charles 'Boyo" <charlesboyo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 2, 2012 at 10:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Jul 2, 2012, at 5:13 PM, Myklebust, Trond wrote:
>
>> On Mon, 2012-07-02 at 16:35 -0400, Chuck Lever wrote:
>>> On Jul 2, 2012, at 4:22 PM, Charles 'Boyo wrote:
>>>
>>>> On Mon, Jul 2, 2012 at 3:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>
>>>>> Usually we see this behavior because of a race between an OPEN with delegation and a delegation recall.  In this case, however, the client is actively returning a READ
>>>>> delegation, then proceeding to use it anyway.  I don't see the server's recall callback, though, and there are other indications that this trace is not complete. So it's hard
>>>>> to be 100% confident.
>>>>>
>>>> The trace is not complete, it includes just enough information to
>>>> explain the problem.
>>>> However I can confirm the service did not send a recall callback, the
>>>> client returned the delegation of its own "free will".
>>>
>>> The callback would come on a separate TCP connection.  I can't think of a reason that a client would return a delegation by itself and then subsequently start to use it.
>>
>> I can: there are a number of servers out there that violate the spec by
>> returning a delegation as part of an OPEN(CLAIM_DELEGATE_CUR). Usually
>> those broken servers will send the exact same stateid as the delegation
>> that is being returned.
>
> The OPEN in frame 7 is a CLAIM_NULL OPEN, isn't it?
>
The OPEN in this case is a CLAIM_NULL and I have re-examined my
network dump, there was no call back from the server.
So why would the client returns a delegation voluntarily and then re-use it?

>>>> Is it possible is a scheduling issue of some sort, where the READ
>>>> should have been sent ahead of the DELEGRETURN but somehow got mixed
>>>> up?

>>> Or possibly that the DELEGRETURN doesn't actually remove the delegation state ID until the server has replied, and the READ request was sent before the DELEGRETURN
>>> reply arrived at the client.

Indeed, the READ was issued after the DELEGRETURN but before the
response to it. Is it possible to check if this is expected behavior?
