Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:61575 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab1FKBqa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 21:46:30 -0400
Received: by vxi39 with SMTP id 39so2616184vxi.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2011 18:46:29 -0700 (PDT)
In-Reply-To: <4DF28983.8000604@tonian.com>
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com>
 <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com>
 <20110609135846.GA32565@merit.edu> <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
 <4DF139B1.7070106@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D221@MX09A.corp.emc.com>
 <4DF20F07.4090804@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D2AC@MX09A.corp.emc.com>
 <4DF26F34.8080008@tonian.com> <BANLkTikbrBJL3K-v2Ecto1FfZ32QQwF8dw@mail.gmail.com>
 <4DF28983.8000604@tonian.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Sat, 11 Jun 2011 09:46:09 +0800
Message-ID: <BANLkTik7swvmbYvpvpcyT7jtdit-UCke=Q@mail.gmail.com>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
To: Benny Halevy <benny@tonian.com>
Cc: Fred Isaman <iisaman@netapp.com>, tao.peng@emc.com, rees@umich.edu,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

On Sat, Jun 11, 2011 at 5:15 AM, Benny Halevy <benny@tonian.com> wrote:
> On 2011-06-10 16:03, Fred Isaman wrote:
>> On Fri, Jun 10, 2011 at 3:23 PM, Benny Halevy <benny@tonian.com> wrote:
>>>
>>> A simple algorithm I can suggest is:
>>> - on initialization, calculate and save, per layout driver
>>>  - maximum layout size
>>
>> I must be misunderstanding something.  Layout size has nothing to do
>> with io size (other than the obvious fact that you want the layout >
>> io).
>
> Exactly, and if the layouts you get from the server are too small
> it's hard to do efficient I/O (modulo layout segment merging
> or gathering)
>
>>
>> I don't know about the object driver, but for both the file and block
>> drivers the client wants as much as the server will give it.
>>
>
> For blocks the message buffer size (as mentioned below) may be
> a limiting factor hence the limit.
It is true that message buffer size can limit the number of extents
returned by block server. But the length that each extent is
addressing is unknown. It can be of any size from layout_blksize to
even larger than file size), determined by the file's on disk layout.
Client cannot guess maximum segment size based on message buffer size.

> Another constraint for blocks and for objects to some extent is
> provisional allocation where you don't want to just arbitrarily
> ask for artificially large write layouts and this may be interpreted
> as intent to write to the whole range and will result in excessive
> provisional allocation of resources.
>
> Bottom line, I completely agree with "the client wants as much as the
> server will give it" so it should ask for what it needs and let the
> server decide whether to extend or trim the range if need be.
>
> Benny
>
>> Fred
>>
>>>    - take into account csr_fore_chan_attrs.ca_maxresponsesize and possible other parameters
>>>  - keep a working copy of the maximum value and the calculated copy.
>>>  - alignment value.
>>> - on miss, see if there's an adjacent layout segment in cache
>>> - if found, ask for twice the found segment size, up to the maximum value,
>>>  aligned on the alignment value.
>>> - if the server returns less the layoutget range, keep note of the returned length
>>>  (but not adjust maximum yet, as the server may return a short segment for various
>>>   reasons)
>>> - if the server is consistent about returning less than was asked, adjust the
>>>  - working copy of the maximum length
>>> - if the maximum was adjusted try bumping it up after X (TBD) layoutgets or T seconds
>>>  to see if that was just due to high load or conflicts on the server
>>> - on any error returned for LAYOUTGET reset the algorithm parameters
>>> - on session reestablishment recalculate maximums.
>>>
>>> Benny
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Thanks,
-Bergwolf
