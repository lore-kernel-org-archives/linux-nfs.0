Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36246 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757914Ab3DYVRH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 17:17:07 -0400
Message-ID: <51799D52.1040903@opengridcomputing.com>
Date: Thu, 25 Apr 2013 16:17:06 -0500
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Tom Talpey <tom@talpey.com>
CC: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Yan Burman <yanb@mellanox.com>, "Atchley, Scott" <atchleyes@ornl.gov>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <CABgxfbHShU7aEttJ35vdAjXduPFFj8+E4=5LZqOgh4e=5bax5Q@mail.gmail.com> <CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com> <517823E0.4000402@talpey.com> <CABgxfbHePAyq6AH9TFKZKUmwEHOupuYUnfc1W99HAuDkYddUqQ@mail.gmail.com> <51798C51.50209@talpey.com>
In-Reply-To: <51798C51.50209@talpey.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/25/13 3:04 PM, Tom Talpey wrote:
> On 4/25/2013 1:18 PM, Wendy Cheng wrote:
>> On Wed, Apr 24, 2013 at 11:26 AM, Tom Talpey <tom@talpey.com> wrote:
>>>> On Wed, Apr 24, 2013 at 9:27 AM, Wendy Cheng <s.wendy.cheng@gmail.com>
>>>> wrote:
>>>>>
>>>> So I did a quick read on sunrpc/xprtrdma source (based on OFA 1.5.4.1
>>>> tar ball) ... Here is a random thought (not related to the rb tree
>>>> comment).....
>>>>
>>>> The inflight packet count seems to be controlled by
>>>> xprt_rdma_slot_table_entries that is currently hard-coded as
>>>> RPCRDMA_DEF_SLOT_TABLE (32) (?).  I'm wondering whether it could help
>>>> with the bandwidth number if we pump it up, say 64 instead ? Not sure
>>>> whether FMR pool size needs to get adjusted accordingly though.
>>>
>>> 1)
>>>
>>> The client slot count is not hard-coded, it can easily be changed by
>>> writing a value to /proc and initiating a new mount. But I doubt that
>>> increasing the slot table will improve performance much, unless this is
>>> a small-random-read, and spindle-limited workload.
>>
>> Hi Tom !
>>
>> It was a shot in the dark :)  .. as our test bed has not been setup
>> yet .However, since I'll be working on (very) slow clients, increasing
>> this buffer is still interesting (to me). I don't see where it is
>> controlled by a /proc value (?) - but that is not a concern at this
>
> The entries show up in /proc/sys/sunrpc (IIRC). The one you're looking
> for is called rdma_slot_table_entries.
>
>> moment as /proc entry is easy to add. More questions on the server
>> though (see below) ...
>>
>>>
>>> 2)
>>>
>>> The observation appears to be that the bandwidth is server CPU limited.
>>> Increasing the load offered by the client probably won't move the needle,
>>> until that's addressed.
>>>
>>
>> Could you give more hints on which part of the path is CPU limited ?
>
> Sorry, I don't. The profile showing 25% of the 16-core, 2-socket server
> spinning on locks is a smoking, flaming gun though. Maybe Tom Tucker
> has some ideas on the srv rdma code, but it could also be in the sunrpc
> or infiniband driver layers, can't really tell without the call stacks.

The Mellanox driver uses red-black trees extensively for resource 
management, e.g. QP ID, CQ ID, etc... When completions come in from the 
HW, these are used to find the associated software data structures I 
believe. It is certainly possible that these trees get hot on lookup when 
we're pushing a lot of data. I'm surprised, however, to see 
rb_insert_color there because I'm not aware of any where that resources 
are being inserted into and/or removed from a red-black tree in the data path.

They are also used by IPoIB and the IB CM, however, connections should not 
be coming and going unless we've got other problems. IPoIB is only used by 
the IB transport for connection set up and my impression is that this 
trace is for the IB transport.

I don't believe that red-black trees are used by either the client or 
server transports directly. Note that the rb_lock in the client is for 
buffers; not, as the name might imply, a red-black tree.

I think the key here is to discover what lock is being waited on. Are we 
certain that it's a lock on a red-black tree and if so, which one?

Tom
>
>> Is there a known Linux-based filesystem that is reasonbly tuned for
>> NFS-RDMA ? Any specific filesystem features would work well with
>> NFS-RDMA ? I'm wondering when disk+FS are added into the
>> configuration, how much advantages would NFS-RDMA get when compared
>> with a plain TCP/IP, say IPOIB on CM , transport ?
>
> NFS-RDMA is not really filesystem dependent, but certainly there are
> considerations for filesystems to support NFS, and of course the goal in
> general is performance. NFS-RDMA is a network transport, applicable to
> both client and server. Filesystem choice is a server consideration.
>
> I don't have a simple answer to your question about how much better
> NFS-RDMA is over other transports. Architecturally, a lot. In practice,
> there are many, many variables. Have you seen RFC5532, that I cowrote
> with the late Chet Juszczak? You may find it's still quite relevant.
> http://tools.ietf.org/html/rfc5532
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

