Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57898 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab2HOLup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2012 07:50:45 -0400
Received: by wibhr14 with SMTP id hr14so1350568wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Aug 2012 04:50:43 -0700 (PDT)
Message-ID: <502B8CF3.6020309@tonian.com>
Date: Wed, 15 Aug 2012 14:50:11 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        Idan Keidar <idank@tonian.com>, Lev Solomonov <solo@tonian.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>  <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>  <1344522979.23523.2.camel@lade.trondhjem.org>  <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>  <1344526780.25447.6.camel@lade.trondhjem.org> <502A02B2.2020700@tonian.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA93A372D@SACEXCMBX04-PRD.hq.netapp.com>  <CA+a=Yy7SgNGeVzM1VNvn+nGAVTpJT6uOLn=AfNsvQJsu6Au1Wg@mail.gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93A3B3C@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A3B3C@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-08-14 17:53, Myklebust, Trond wrote:
> On Tue, 2012-08-14 at 22:30 +0800, Peng Tao wrote:
>> On Tue, Aug 14, 2012 at 9:45 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Tue, 2012-08-14 at 10:48 +0300, Benny Halevy wrote:
>>>> On 2012-08-09 18:39, Myklebust, Trond wrote:
>>>>> On Thu, 2012-08-09 at 23:01 +0800, Peng Tao wrote:
>>>>>> On Thu, Aug 9, 2012 at 10:36 PM, Myklebust, Trond
>>>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>>>> On Thu, 2012-08-09 at 22:30 +0800, Peng Tao wrote:
>>>>>>>> On Thu, Aug 9, 2012 at 4:21 AM, Trond Myklebust
>>>>>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>>>>>> Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
>>>>>>>>> disconnected data server) we've been sending layoutreturn calls
>>>>>>>>> while there is potentially still outstanding I/O to the data
>>>>>>>>> servers. The reason we do this is to avoid races between replayed
>>>>>>>>> writes to the MDS and the original writes to the DS.
>>>>>>>>>
>>>>>>>>> When this happens, the BUG_ON() in nfs4_layoutreturn_done can
>>>>>>>>> be triggered because it assumes that we would never call
>>>>>>>>> layoutreturn without knowing that all I/O to the DS is
>>>>>>>>> finished. The fix is to remove the BUG_ON() now that the
>>>>>>>>> assumptions behind the test are obsolete.
>>>>>>>>>
>>>>>>>> Isn't MDS supposed to recall the layout if races are possible between
>>>>>>>> outstanding write-to-DS and write-through-MDS?
>>>>>>>
>>>>>>> Where do you read that in RFC5661?
>>>>>>>
>>>>>> That's my (maybe mis-)understanding of how server works... But looking
>>>>>> at rfc5661 section 18.44.3. layoutreturn implementation.
>>>>>> "
>>>>>> After this call,
>>>>>>    the client MUST NOT use the returned layout(s) and the associated
>>>>>>    storage protocol to access the file data.
>>>>>> "
>>>>>> And given commit 0a57cdac3f, client is using the layout even after
>>>>>> layoutreturn, which IMHO is a violation of rfc5661.
>>>>>
>>>>> No. It is using the layoutreturn to tell the MDS to fence off I/O to a
>>>>> data server that is not responding. It isn't attempting to use the
>>>>> layout after the layoutreturn: the whole point is that we are attempting
>>>>> write-through-MDS after the attempt to write through the DS timed out.
>>>>>
>>>>
>>>> I hear you, but this use case is valid after a time out / disconnect
>>>> (which will translate to PNFS_OSD_ERR_UNREACHABLE for the objects layout)
>>>> In other cases, I/Os to the DS might obviously be in flight and the BUG_ON
>>>> indicates that.
>>>>
>>>> IMO, the right way to implement that is to initially mark the lsegs invalid
>>>> and increment plh_block_lgets, as we do today in _pnfs_return_layout
>>>> but actually send the layout return only when the last segment is dereferenced.
>>>
>>> This is what we do for object and block layout types, so your
>>> objects-specific objection is unfounded.
>>>
>> object layout is also doing layout return on IO error (commit
>> fe0fe83585f8). And it doesn't take care of draining concurrent
>> in-flight IO. I guess that's why Boaz saw the same BUG_ON.
> 
> Yes. I did notice that code when I was looking into this. However that's
> Boaz's own patch, and it _only_ applies to the objects layout type. I
> assumed that he had tested it when I applied it...
> 
> One way to fix that would be to keep a count of "outstanding
> read/writes" in the layout, so that when the error occurs, and we want
> to fall back to MDS, we just increment plh_block_lgets, invalidate the
> layout, and then let the outstanding read/writes fall to zero before
> sending the layoutreturn.

Sounds reasonable to me too.

> If the objects layout wants to do that, then I have no objection. As
> I've said multiple times, though, I'm not convinced we want to do that
> for the files layout.
> 

I just fear that removing the BUG_ON will prevent us from detecting cases
where a LAYOUTRETURN is sent while there are layout segments in use
in the error free or non-timeout case.

Benny
