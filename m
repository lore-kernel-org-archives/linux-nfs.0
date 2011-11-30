Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54026 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab1K3DI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 22:08:28 -0500
Message-ID: <4ED59E1D.3020705@panasas.com>
Date: Tue, 29 Nov 2011 19:08:13 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>,
        <bhalevy@tonian.com>, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>      <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>     <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>    <1322606842.11286.33.camel@lade.trondhjem.org>    <4ED563AC.5040501@panasas.com>   <1322609431.11286.56.camel@lade.trondhjem.org>   <4ED577AE.2060209@panasas.com>  <1322614718.11286.104.camel@lade.trondhjem.org>  <4ED58ADE.8010809@panasas.com> <1322618839.11286.130.camel@lade.trondhjem.org>
In-Reply-To: <1322618839.11286.130.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 06:07 PM, Trond Myklebust wrote:
>>
>> 1. The 1000 DSes problem is separate from the segments problem. The devices
> 
> Errr... That was the problem that you used to justify the need for a
> full implementation of layout segments in the pNFS files case...
> 

What I do not understand? I said what?

>> solution is on the way. The device cache is all but ready to see some
>>    periodic scan that throws 0 used devices. We never got to it because
>>    currently every one is testing with up to 10 devices and I'm using upto
>>    128 devices which is just fine. The load is marginal so far.
>>    But I promise you it is right here on my to do list. After some more
>>    pressed problem.
>>    Lets say one thing this subsystem is the same regardless of if the
>>    1000 devices are refed by 1 segment or by 10 segments. Actually if
>>    by 10 then I might get rid of some and free devices.
>>
>> 2. The many segments problem. There are not that many. It's more less
>>    a segment for every 2GB so an lo_seg struct for so much IO is not
>>    noticeable.
> 
> Where do you get that 2GB number from?
> 

It's just the numbers that I saw and used. I'm just giving you an example
usage. The numbers guys are looking for are not seg for every 4K but seg
every Giga. That's what I'm saying. When you asses the problem you should
attack the expected and current behavior.

When a smart ass Server comes and serves 4k segments and all it's Clients go
OOM, how long that Server will stay in business? I don't care about him
I care about a properly set balance and that is what we arrived at both in
Panasas and else where.

>> At the upper bound we do not have any problem because Once the system is
>>    out of memory it will start to evict inodes. And on evict we just return
>>    them. Also ROC Servers we forget them on close. So so far all our combined
>>    testing did not show any real memory pressure caused by that. When shown we
>>    can start discarding segs in an LRU fashion. There are all the mechanics
>>    to do that, we only need to see the need.
> 
> It's not necessarily that simple: if you are already low on memory, them
> LAYOUTGET and GETDEVICE will require you to allocate more memory in
> order to get round to cleaning those dirty pages.
> There are plenty of situations where the majority of dirty pages belong
> to a single file. If that file is one of your 1000 DS-files and it
> requires you to allocate 1000 new device table entries...
> 

No!!! That is the all-file layout problem. In a balanced and segmented
system. You don't. You start by getting a small number of devices corresponding
to the first seg. send the IO, when the IO returns, given memory pressure
you can free the segment, and it's ref-ed devices and continue with the next
seg. You can do this all day visiting all the 1000 devices with never having
more then 10 at a time.

The ratios are fine. For every 1GB of dirty pages I have one layout and 10
devices. It's marginal and expected memory needs for IO. Should I start with
the block layer scsi layer iscsi LLD networking stack, they all need more
memory to clear memory. If the system makes sure that dirty pages pressure
starts soon enough the system should be fine.

>> 3. The current situation is fine and working and showing great performance
>>    for objects and blocks. And it is all in the Generic part so it should just
>>    be the same for files. I do not see any difference.
>>
>>    The only BUG I see is the COMMIT and I think we know how to fix that
> 
> I haven't seen any performance numbers for either, so I can't comment.
> 

890MB single 10G client single stream.
3.6G 16 clients N x N from a 4.0G theoretical storage limit.

Please Believe me nice numbers. It is all very balanced. 2G segments
10 devices each segment. Smooth as silk

>>
>> LRU. Again there are not more than a few segments per inode. It's not
>> 1000 like devices.
> 
> Again, the problem for files shouldn't be the number of segments, it is
> number of devices.
> 

Right! And the all-file layout makes it worse. With segments the DSs can
be de-refed early making room for new devices. It is all a matter of keeping
your numbers balanced. When you get it wrong your client performance drops.

All we (the client need to care) is that we don't crash and do the right
thing. If a server returns a 1000 DSs segment then we return E-RESOURCE.
Hell the xdr buffer for get device info will be much to small long before
that. But is the server returns 10 devices at a time that can be discarded
before the next segment then we are fine, right?

>>
>> All your above concerns are true and interesting. I call them a rich man problems.
>> But they are not specific to files-LO they are generic to all of us. Current situation
>> satisfies us for blocks and objects. The file guys out there are jealous.
> 
> I'm not convinced that the problems are the same. objects, and
> particularly blocks, appear to treat layout segments as a form of byte
> range lock. There is no reason for a pNFS files server to do so.
> 

Trond this is not fair. You are back to your old self again. A files layout
guy just told you that it's cluster's data layout cannot be described in a
single deviceinfo+layout and his topology requires segmented topology. Locks or
no locks. that's beside the issue.

In objects only for RAID5 it is true what you say because you cannot have
two clients writing the same stripe. But for RAID0 there is no such restriction.
For a long time I served all-file until I had a system with more than 21 objects
the 21 objects is the limit of the layout_get buffer from client. So now I serve
10 device segments at a time, which gives me a nice balance. And actually works
much better than the old all-file way. It is liter Both on the Server implementation
and on the Client.

You are dodging our problem. There are true servers out there that have typologies
that needs segments in exactly the type of numbers that I'm talking about. The
current implementation is just fine. All they want is the restriction lifted and
the COMMIT bug fixed. They do not ask for anything else, more.

And soon enough I will demonstrate to you a (virtual) 1000 devices file working
just fine. Once I get that devices-cache LRU in place.

Lets say that the RAID0 objects behavior is identical to the files-LO which is
RAID0 only. (No recalls on stripe conflicts) so if it works very nice for
objects I don't see why it should have problems for files?

If I send you a patch that fixes the COMMIT problem in files layout
will you consider it?

Heart
