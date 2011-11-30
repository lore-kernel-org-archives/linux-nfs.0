Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51318 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757058Ab1K3AY0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 19:24:26 -0500
Message-ID: <4ED577AE.2060209@panasas.com>
Date: Tue, 29 Nov 2011 16:24:14 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>    <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>   <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>  <1322606842.11286.33.camel@lade.trondhjem.org>  <4ED563AC.5040501@panasas.com> <1322609431.11286.56.camel@lade.trondhjem.org>
In-Reply-To: <1322609431.11286.56.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 03:30 PM, Trond Myklebust wrote:
> On Tue, 2011-11-29 at 14:58 -0800, Boaz Harrosh wrote: 
>>
>> The kind of typologies I'm talking about a single layout get ever 1GB is
>> marginal to the gain I get in deploying 100 of DSs. I have thousands of
>> DSs I want to spread the load evenly. I'm limited by the size of the layout
>> (Device info in the case of files) So I'm limited by the number of DSs I can
>> have in a layout. For large files these few devices become an hot spot all
>> the while the rest of the cluster is idle.
> 
> I call "bullshit" on that whole argument...
> 
> You've done sod all so far to address the problem of a client managing

sod? I don't know this word?

> layout segments for a '1000 DS' case. Are you expecting that all pNFS
> object servers out there are going to do that for you? How do I assume
> that a generic pNFS files server is going to do the same? As far as I
> know, the spec is completely moot on the whole subject.
> 

What? The all segments thing is in the Generic part of the spec and is not
at all specific or even specified in the objects and blocks RFCs.

There is no layout in the spec, there are only layout_segments. Actually
what we call layout_segments, in the spec, it is simply called a layout.

The client asks for a layout (segment) and gets one. An ~0 length one
is just a special case. Without layout_get (segment) there is no optional
pnfs support.

So we are reading two different specs because to me it clearly says
layout - which is a segment.

Because the way I read it the pNFS is optional in 4.1. But if I'm a
pNFS client I need to expect layouts (segments)

> IOW: I'm not even remotely interested in your "everyday problems" if
> there are no "everyday solutions" that actually fit the generic can of
> spec worms that the pNFS layout segments open.

That I don't understand. What "spec worms that the pNFS layout segments open"
Are you seeing. Because it works pretty simple for me. And I don't see the
big difference for files. One thing I learned for the past is that when you
have concerns I should understand them and start to address them. Because
your insights are usually on the Money. If you are concerned then there is
something I should fix.

Fred told me about his COMMIT problem. And in my opinion he is doing it
the wrong way.

He is trying to consolidate commits across lo_segments. But to the contrary
he should keep it as is and bound the commit to segments boundary.
If a server is giving out all-file then above problem is mute.

but if the Server gave out segments. Then for him he anticipates all operations
segmented. Usually the servers I saw will always have different DSs on these other
segments and the hard work will not matter at all. If not then Such a server will
anticipate that the COMMITS will be finer then what could theoretically be done.
And could take that into account. In anyway that's what they'll get.

So please don't solve for the theoretical case that no one uses. (Same DSs repeat
in the next segments)

> 
>>>> Two: There are already file-layout servers out there (multiple) which are
>>>>      waiting for the Linux files-layout segment support, because the underline
>>>>      FS requires Segments and now they do not work with the Linux client. These
>>>>      are CEPH and GPFS and more.
>>>
>>> Then they will have a _long_ wait....
>>>
>>
>> OK, so now I understand. Because when I was talking to Fred before BAT and during
>> It was very very peculiar to me why he is not already done with that simple stuff.
>> Because usually Fred is such a brilliant fast programmer that I admire, and that simple
>> crap?
>>
>> But now that explains
> 
> Yes. It's all a big conspiracy, and we're deliberately holding Fred's
> genius back in order to disappoint you...
> 

My disappointment is that I think it is important for me that the pNFS protocol can
take a strong-hold in the HPC and cloud market (and everywhere). And for that to happen
all layout types including files must excel and shine. I'm constantly trying to architect
an HPC cluster class parallel Filesystem with Files-layout as well. But keeps getting hits
from small trivialities that make the all difference. (Another example is that EOF talk
we had the other day)

I'm a patience guy I can wait until you guys see the light.

Thanks
Heart
