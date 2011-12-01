Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47915 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab1LABS3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 20:18:29 -0500
Message-ID: <4ED6D5D8.9010801@panasas.com>
Date: Wed, 30 Nov 2011 17:18:16 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Benny Halevy <bhalevy@tonian.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>, Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH-RESEND 4/4] pnfsblock: do not ask for layout in pg_init
References: <1322888194-3039-1-git-send-email-bergwolf@gmail.com> <4ED62857.7090804@tonian.com> <CA+a=Yy5BYoxVWM+4C6ORex5aOZcLAbUmhY6XE=wBsreGVG7GAA@mail.gmail.com>
In-Reply-To: <CA+a=Yy5BYoxVWM+4C6ORex5aOZcLAbUmhY6XE=wBsreGVG7GAA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2011 05:17 AM, Peng Tao wrote:
>>>
>>> +/* While RFC doesn't limit maximum size of layout, we better limit it ourself. */
>>
>> Why is that?
>> What do these arbitrary numbers represent?
>> If these limits depend on some other system sizes they should reflect the dependency
>> as part of their calculation.
> What I wanted to add here is a limit to stop pg_test() (like object's
> max_io_size) and 2MB is just an experience value...
> 
> Thanks,
> Tao
>>
>> Benny
>>
>>> +#define PNFSBLK_MAXRSIZE (0x1<<22)
>>> +#define PNFSBLK_MAXWSIZE (0x1<<21)

You see this is the basic principal flaw of your scheme. It is equating IO sizes
with lseg sizes.

Lets back up for a second

A. First thing to understand is that any segmenting server be it blocks objects
   or files, will want the client to report to the best of it's knowledge
   the intention of the writing application. Therefor a solution should be
   good for all Three. What ever you are trying to do should not be private to
   blocks and must not conflict with other LO needs.

   Note: that the NFS-write-out stack since it holds back on writing until
   sync time or memory pressure that in most cases at the point of IO has at
   it's disposal the complete application IO in it's page collection per file.
   (Exception is very large writes which is fine to split, given resources condition
    on the client)

   So below when I say application we can later mean the complete page list
   available per inode at the time of write-out.

B. The *optimum* for any segmented server is:
   (and addressing Trond's concern of seg list exploding and never freeing up)

B.1. If an application will write O..N of the file
1. Get one lo_seg of 0..N
2. IO at max_io from O to N until done.
3. Return or forget the lo_seg

B.2. In the case of random IO O1..N1, O2..N2,..., On..Nn

For objects and files (segmented) the optimum is still:
1. Get one lo_seg of 01..Nn
2. IO at max_io for each Ox..Nx until done.
   (objects: max_io is a factor of BIO sizes group boundary and alignments.
    files: max_io is stripe_unit)
3. Return or forget the 1 lo_seg

For blocks the optimum is
1. Get n lo_segs of O1..N1, O2..N2,..., On..Nn
2. IO at max_io for each Ox..Nx until done.
3. Return or forget any Ox..Nx who's IO is done

You can see that stage 2. for any kind of LO and in either B.1 or B.2 cases
is the same. 
And this is, as the author intended, the .bg_init -> pg_test -> pg_IO.

For blocks with in .write_paglist there is an internal loop that re-slices the
requested linear pagelist to extents, possibly slicing each extent at bio_size
boundaries. At files and objects this slicing (though I admit very different)
actually happen at .pg_test, so at .write_paglist the request is sent in full.

C. So back to our problem:

C.1 NACK on your patchset. You are shouting to the roof how the client must
    report to the Server (as hint) to the best of it's knowledge what the
    application is going to do. And then you sneakily introduce an IO_MAX limitation.

    This you MUST fix. Ether you send good server hint for the anticipated
    application IO or not at all.

    (The Server can always introduce it's own slicing and limits)

    You did all this because you have circumvented the chance to do so at .pg_test
    because you want the .bg_init -> pg_test -> pg_IO. loop to be your 
    O1..N1, O2..N2,...,On..Nn parser.

C.2 You must work out a system which will satisfy not only blocks (MPFS) server
    But any segmenting server out there. blocks objects or files (segmented)
    By reporting the best information you have and letting the Server do it's
    decisions.

    Now by postponing the report to after .pg_test -> .pg_IO you break the way
    objects and files IO slicing works, and leaves them in the dark. I'm not sure
    you really mean that each LO needs to do it's own private hacks?


C.3 Say we go back to the drawing board and want to do the stage 1 above of
    sending the exact information to server, be it B.1 or B.2.

    a. We want it at .pg_init so we have a layout at .pg_test to inspect.

       Done properly will let you, in blocks, slice by extents at .pg_test
       and .write_pages can send the complete paglist to md (bio chaining)

    b. Say theoretically that we are willing to spend CPU and memory to collect
       that information, like for example also pre-loop the page-list and/or
       call the LO for the final decision.

    So my all point is that b. above should eventually happen but efficiently by
    pre-collecting some counters. (Remember that we already saw all these pages
    in generic nfs at the vfs .write_pages vector)

    Then since .pg_init is already called into LO, just change the API so the
    LO have all the needed information available be it B.1 or B.2 and in return
    will pass on to pnfs.c the actual lo_seg size optimal. In B.1 they all
    send the same thing. In B.2 they differ.

    We can start by doing all the API changes so .pg_init can specify and
    return the suggested lo_size. And perhaps we add to the nfs_pageio_descriptor,
    passed to .pg_init, a couple of members describing above
    O1 - the index of the first page
    N1 - The length up to the firs hole
    Nn - Highest written page

    
    At first version:
      A good approximation which gives you an exact middle point
      between blocks B.2 and objects/files B.2, is dirty count.
    At later patch:
      Have generic NFS collect the above O1, N1, and Nn for you and base
      your decision on that.


And stop the private blocks hacks and the IO_MAX capping on the lo_seg
size.

Boaz
