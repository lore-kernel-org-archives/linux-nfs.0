Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:57296 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab2HNObE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 10:31:04 -0400
Received: by ghrr11 with SMTP id r11so495370ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Aug 2012 07:31:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A372D@SACEXCMBX04-PRD.hq.netapp.com>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
 <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
 <1344522979.23523.2.camel@lade.trondhjem.org> <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>
 <1344526780.25447.6.camel@lade.trondhjem.org> <502A02B2.2020700@tonian.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93A372D@SACEXCMBX04-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 14 Aug 2012 22:30:43 +0800
Message-ID: <CA+a=Yy7SgNGeVzM1VNvn+nGAVTpJT6uOLn=AfNsvQJsu6Au1Wg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        Idan Keidar <idank@tonian.com>, Lev Solomonov <solo@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 14, 2012 at 9:45 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-08-14 at 10:48 +0300, Benny Halevy wrote:
>> On 2012-08-09 18:39, Myklebust, Trond wrote:
>> > On Thu, 2012-08-09 at 23:01 +0800, Peng Tao wrote:
>> >> On Thu, Aug 9, 2012 at 10:36 PM, Myklebust, Trond
>> >> <Trond.Myklebust@netapp.com> wrote:
>> >>> On Thu, 2012-08-09 at 22:30 +0800, Peng Tao wrote:
>> >>>> On Thu, Aug 9, 2012 at 4:21 AM, Trond Myklebust
>> >>>> <Trond.Myklebust@netapp.com> wrote:
>> >>>>> Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
>> >>>>> disconnected data server) we've been sending layoutreturn calls
>> >>>>> while there is potentially still outstanding I/O to the data
>> >>>>> servers. The reason we do this is to avoid races between replayed
>> >>>>> writes to the MDS and the original writes to the DS.
>> >>>>>
>> >>>>> When this happens, the BUG_ON() in nfs4_layoutreturn_done can
>> >>>>> be triggered because it assumes that we would never call
>> >>>>> layoutreturn without knowing that all I/O to the DS is
>> >>>>> finished. The fix is to remove the BUG_ON() now that the
>> >>>>> assumptions behind the test are obsolete.
>> >>>>>
>> >>>> Isn't MDS supposed to recall the layout if races are possible between
>> >>>> outstanding write-to-DS and write-through-MDS?
>> >>>
>> >>> Where do you read that in RFC5661?
>> >>>
>> >> That's my (maybe mis-)understanding of how server works... But looking
>> >> at rfc5661 section 18.44.3. layoutreturn implementation.
>> >> "
>> >> After this call,
>> >>    the client MUST NOT use the returned layout(s) and the associated
>> >>    storage protocol to access the file data.
>> >> "
>> >> And given commit 0a57cdac3f, client is using the layout even after
>> >> layoutreturn, which IMHO is a violation of rfc5661.
>> >
>> > No. It is using the layoutreturn to tell the MDS to fence off I/O to a
>> > data server that is not responding. It isn't attempting to use the
>> > layout after the layoutreturn: the whole point is that we are attempting
>> > write-through-MDS after the attempt to write through the DS timed out.
>> >
>>
>> I hear you, but this use case is valid after a time out / disconnect
>> (which will translate to PNFS_OSD_ERR_UNREACHABLE for the objects layout)
>> In other cases, I/Os to the DS might obviously be in flight and the BUG_ON
>> indicates that.
>>
>> IMO, the right way to implement that is to initially mark the lsegs invalid
>> and increment plh_block_lgets, as we do today in _pnfs_return_layout
>> but actually send the layout return only when the last segment is dereferenced.
>
> This is what we do for object and block layout types, so your
> objects-specific objection is unfounded.
>
object layout is also doing layout return on IO error (commit
fe0fe83585f8). And it doesn't take care of draining concurrent
in-flight IO. I guess that's why Boaz saw the same BUG_ON.

-- 
Thanks,
Tao
