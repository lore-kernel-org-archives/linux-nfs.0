Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40247 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab1FLSqv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 14:46:51 -0400
Received: by vxi39 with SMTP id 39so3204289vxi.19
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2011 11:46:50 -0700 (PDT)
In-Reply-To: <4DF4CFE9.7070000@panasas.com>
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com>
 <20110609114929.GA28157@merit.edu> <4DF0CB5D.60000@panasas.com>
 <20110609135846.GA32565@merit.edu> <BANLkTi=0yr1ecyf30+OQcFipJsHOk=4Y4w@mail.gmail.com>
 <4DF139B1.7070106@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D221@MX09A.corp.emc.com>
 <4DF20F07.4090804@tonian.com> <F19688880B763E40B28B2B462677FBF805BED9D2AC@MX09A.corp.emc.com>
 <4DF26F34.8080008@tonian.com> <4DF2A6AA.8050608@panasas.com>
 <BANLkTin+Z=sxrNkfyktqH_m5_dhsiHLf5w@mail.gmail.com> <4DF4CFE9.7070000@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 13 Jun 2011 02:46:30 +0800
Message-ID: <BANLkTikV8oRdAsfnMYaqMvBUEP_ottA5xQ@mail.gmail.com>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <benny@tonian.com>, tao.peng@emc.com, rees@umich.edu,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jun 12, 2011 at 10:40 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 06/10/2011 07:19 PM, Peng Tao wrote:
>> On Sat, Jun 11, 2011 at 7:20 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> On 06/10/2011 12:23 PM, Benny Halevy wrote:
>>>> On 2011-06-10 10:09, tao.peng@emc.com wrote:
>>>>
>>>> A simple algorithm I can suggest is:
>>>> - on initialization, calculate and save, per layout driver
>>>>   - maximum layout size
>>>>     - take into account csr_fore_chan_attrs.ca_maxresponsesize and possible other parameters
>>>>   - keep a working copy of the maximum value and the calculated copy.
>>>>   - alignment value.
>>>> - on miss, see if there's an adjacent layout segment in cache
>>>> - if found, ask for twice the found segment size, up to the maximum value,
>>>>   aligned on the alignment value.
>>>> - if the server returns less the layoutget range, keep note of the returned length
>>>>   (but not adjust maximum yet, as the server may return a short segment for various
>>>>    reasons)
>>>> - if the server is consistent about returning less than was asked, adjust the
>>>>   - working copy of the maximum length
>>>> - if the maximum was adjusted try bumping it up after X (TBD) layoutgets or T seconds
>>>>   to see if that was just due to high load or conflicts on the server
>>>> - on any error returned for LAYOUTGET reset the algorithm parameters
>>>> - on session reestablishment recalculate maximums.
>>>>
>>>> Benny
>>>>
>>>
>>> I completely disagree with all this. NACK!
>>>
>>> The only proper thing a client can do is ask for what it needs, and only the application
>>> can do that, because at the VFS level it is only second guessing, and is completely
>>> pointless.
>>>
>>> The only one that can know about structure, alignments, optimal IO sizes and layouts
>>> is the server. The server even have more information to second guess the application
>>> from the file size information and it's share and lock disposition. Please see my
>>> simple Server side algorithm.
>> Well, IMO, client is closer to applications and should have a better
>> position at "guessing" application's workload.
>>
>> A simple example, when a client asks for a layout, server would have
>> no idea if client is doing layout prefetch, or if it really need that
>> range to complete its work. But the client knows it for sure.
>>
>
> What is layout prefetch? we don't do any in the Linux client.
>
> And your example does not make any sense. If a theoretical stupid client does
> "layout prefetch" what ever that means, how is it related to the application?
The example is just showing you that sometimes server does not know
everything. And the thing it does not know, can have some impact on
application IO performance. If client is asking for more than it needs
and server is returning more than client asks for, application
performance is impacted for sure.

>
> There is not a single information a client has the the server does not. Look at
> your patch. Set an arbitrary value at client setup. That same arbitrary value
> can be setup at server. Look at benny's algorithm. It can be done just the same
> at the server side. (Which does not mean it is a good algorithm)
True. And both client and server should have that some kind of
algorithms implemented. Server can be smart. But it does not prevent
client from being smart too. There can always be naive clients and
naive servers. We can't prevent users from using them. And when users
are dealing with naive servers, we can do better with the algorithm at
client side, other than simply telling them "it's your fault not using
the smart servers!".

>
> Just take that patch of yours, but instead of at client side. Put it at server
> side. You will achieve exact same results. Only you configure one server instead
> of every client.
>
> And no way in hell I let that go into the Linux generic client!
While taking your side so firmly, would you mind telling why such kind
of algorithm cannot be implemented at client side?

>
> Boaz
>
>>>
>>> Because you must understand one most important thing. Any smart decision a client can
>>> make will be after it received the layout (stripe_unit, number-of-devices etc..) But
>>> at that time it is too late it already sent the layout_get. Only the server knows
>>> before hand what is the most optimal size. The client should just be a transparent
>>> pipe from application to the server. It should never ever set policy. Only a Server
>>> can/should do that.
>>>
>>> Lets put the efforts and algorithms where they belong, please?
>>>
>>> Boaz
>>>
>>
>>
>>
>
>



-- 
Thanks,
-Bergwolf
