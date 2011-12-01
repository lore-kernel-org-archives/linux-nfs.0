Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60465 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755631Ab1LARdV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:33:21 -0500
Message-ID: <4ED7BA55.8010200@panasas.com>
Date: Thu, 1 Dec 2011 09:33:09 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <tao.peng@emc.com>
CC: <bergwolf@gmail.com>, <bhalevy@tonian.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH-RESEND 4/4] pnfsblock: do not ask for layout in pg_init
References: <1322888194-3039-1-git-send-email-bergwolf@gmail.com> <4ED62857.7090804@tonian.com> <CA+a=Yy5BYoxVWM+4C6ORex5aOZcLAbUmhY6XE=wBsreGVG7GAA@mail.gmail.com> <4ED6D5D8.9010801@panasas.com> <F19688880B763E40B28B2B462677FBF805E5043E4B@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E5043E4B@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2011 09:05 PM, tao.peng@emc.com wrote:
>> -----Original Message-----
> Why return or forget the 1 lo_seg? What you really need to avoid seg
> list exploding is to have LRU based caching and merge them when
> necessary, instead of asking and dropping lseg again and again...
> 

Ya Ya, I'm talking in abstract now giving the all picture. If in our
above case the application has closed the file and will not ever open it
again then I'm right, right? of course once you got it you can keep it
around in a cache. Though I think that with heavy segmenting keeping segs
passed ROC is extremely harder to manage. Be careful with that in current
implementation.

> Removing the IO_MAX limitation can be a second optimization. I was
> hoping to remove it if current IO_MAX thing turns out hurting
> performance. And one reason for IO_MAX is to avoid the likelihood
> that server returns short layout, because current implementation is
> limited to retry nfs_read/write_data as a whole instead of splitting
> it up. I think that if we do it this way, the IO_MAX can be removed
> later when necessary, by introducing a splitting mechanism either on
> nfs_read/write_data or on desc. Now that you ask for it, I think
> following approach is possible:
>
> 1. remove the limit on IO_MAX at .pg_test.
> 2. ask for layout at .pg_doio for the size of current IO desc
> 3. if server returns short layout, split nfs_read/write_data or desc and issue the pagelist covered by lseg.
> 4. do 2 and 3 in a loop until all pages in current desc is handled.
> 

So in effect you are doing what I suggest two passes 
one: what's the next hole,
second: Collect pages slicing by returned lo_seg

Don't you think it is more simple to do a 3 line preliminary
loop in "one:"?

and keep the current code that is now exactly built to do
"second:"

You are suggesting to effectively repeat current code using
the first .pg_init...pg_doio for one: and hacking for blocks
"second:"

I want 3 lines of code for one: and keep second: exactly as is.

<snip>

> Looks like you are suggesting going through the dirty page list twice
> before issuing IO, one just for getting the IO size information and
> another one for page collapsing. The whole point of moving layoutget
> to .pg_doio is to collect real IO size there because we don't know it
> at .pg_init. And it is done without any changes to generic NFS IO
> path. I'm not sure if it is appropriate to change generic IO routine
> to collect the information before .pg_init (I'd be happy too if we
> can do it there).

That's what you are suggesting as well look in your step 4.:
	do 2 and 3 in a loop until all pages in current desc is handled
sounds like another loop on all pages no?

BTW: we are already doing two passes in the system we already looked
through all the pages when building the io desc at .write/read_pages

At first we can do above 3 lines loop in .pg_init. Second we can
just collect that information in generic nfs at the first loop
we are already doing

>>
>>     a. We want it at .pg_init so we have a layout at .pg_test to inspect.
>>
>>        Done properly will let you, in blocks, slice by extents at .pg_test
>>        and .write_pages can send the complete paglist to md (bio chaining)
>>
> Unlike objects and files, blocks don't slice by extents, not at .pg_test, nor at .read/write_pagelist.
>  

What? What do you do? Send a scsi scatter list command?
I don't think so. Somewhere you have to see an extent boundary of the data
and send the continue of the next extent on disk as a new block request
in a new bio with a new disk offset. No?

I'm not saying to do this right away, but you could simplify the code a lot
by slicing by extent inside .pg_test

<>
>>
>>     At first version:
>>       A good approximation which gives you an exact middle point
>>       between blocks B.2 and objects/files B.2, is dirty count.
>>     At later patch:
>>       Have generic NFS collect the above O1, N1, and Nn for you and base
>>       your decision on that.
>>
>
> Well, unless you put both the two parts in... The first version is
> ignoring the fact that blocks MDS cannot give out file stripping
> information as easily as objects and files do. And I will stand
> against it alone because all it does is to benefit objects while
> hurting blocks (files don't care because they use whole file layout,
> at least for now).

Lets make a computerize lets find O1..N1 and put in the Generic
code for everyone objects files-segmented and blocks. Because I
need it two. And I'd like O1..Nn but for first step I'd love
O1..N1 a lot.

Please see my point. You created a system that only blocks can
benefit from unless objects repeats the same exact but duplicated
hacks as blocks.

Please do the *very* simple thing I suggest which we can all enjoy.

> 
> Otherwise, I would suggest having private hack for blocks because we have a real problem to solve.
> 

It's just as real for objects, and files when they will do segments.

My suggestion is to have two helpers at pnfs.c one for blocks and
objects, one for files. Which can be called in .pg_init.
The blocks/objects does a simple loop counting the first contiguous
chunk and asks for a layout, like today. files one just sends
all-file request.

Boaz
