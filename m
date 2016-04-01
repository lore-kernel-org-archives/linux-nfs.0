Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33507 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbcDATij (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2016 15:38:39 -0400
Received: by mail-io0-f171.google.com with SMTP id a129so155006649ioe.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2016 12:38:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEn1Z46VX6JENoGmMMttNM9_TXyoZDfsT+OibhgY0A9hA@mail.gmail.com>
References: <CAN-5tyHEt93VxL2Ysikgn8iZ_auWEWGdGkZ94LMBOa62wHDWMA@mail.gmail.com>
	<CAN-5tyHrYxT-V2fms9vga_Ed+bQ3E+xk7A8fK0N1xYEzm_HtNg@mail.gmail.com>
	<CAHQdGtTxkUjQ+yLip_DrZB305U3NsZp8ZQ3VvkqgJhACPPM+Bg@mail.gmail.com>
	<CAN-5tyGdaQDNF3ALNNBCTmyxeb8n0VCg-4CiS0rLXM+tQbiRUA@mail.gmail.com>
	<CAHQdGtRUFfHZCd3foKWY9nq7ULCSY=RWZM4tgQ3BsE3cnxYD3A@mail.gmail.com>
	<CAN-5tyE9iyRCxMrX1=QkynmS9SEmM1ZSGB0wey7tsVnSYrfMcg@mail.gmail.com>
	<CAHQdGtQjV2u+RrXiM6iKtz9in4zdDWDWi2gnj47-+WSdG=JKzw@mail.gmail.com>
	<CAN-5tyE4OWJrBuP73tMab8NAy0_NzfZvVpSZQeSmpQ+qoDpcjQ@mail.gmail.com>
	<CAHQdGtRPydhrqmqsxLSCAsYHS5iZ1FBO_7uthF_N43N+as2Brw@mail.gmail.com>
	<CAN-5tyEn1Z46VX6JENoGmMMttNM9_TXyoZDfsT+OibhgY0A9hA@mail.gmail.com>
Date: Fri, 1 Apr 2016 15:38:38 -0400
Message-ID: <CAN-5tyHS6J=2gV0HoM67VhqF1i4JYoyH3XWnWW=7FDDxwfbvqg@mail.gmail.com>
Subject: Re: commit 7c2dad99d6 "Don't let the ctime override attribute barriers"
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 31, 2016 at 11:27 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Thu, Mar 31, 2016 at 11:16 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Thu, Mar 31, 2016 at 10:36 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> On Thu, Mar 31, 2016 at 10:21 AM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> On Thu, Mar 31, 2016 at 10:15 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>> On Wed, Mar 30, 2016 at 7:32 PM, Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>>> On Wed, Mar 30, 2016 at 5:51 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>> On Wed, Mar 30, 2016 at 5:45 PM, Trond Myklebust
>>>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>>>>> On Wed, Mar 30, 2016 at 5:02 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>> On Tue, Mar 29, 2016 at 3:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>> I think that patch introduces a problem. Since the checking for the
>>>>>>>>>> change in ctime was removed by the commit it leads to (improper) cache
>>>>>>>>>> invalidation in NFSv3.
>>>>>>>>>>
>>>>>>>>>> Test is write 10240bytes to the server then read it. Expectation is
>>>>>>>>>> not to see read on the wire. In the test the write is spread over
>>>>>>>>>> 3rpcs.
>>>>>>>>>>
>>>>>>>>>> On the 1nd reply
>>>>>>>>>> fattr->gencount=33 nfsi->gencount=32 generation_counter=35
>>>>>>>>>> On the 2nd reply
>>>>>>>>>> fattr->gencount=34 nfsi->gencount=36 generation_counter=36
>>>>>>>>>>
>>>>>>>>>> In the code when processing 2nd reply,
>>>>>>>>>> nfs_post_op_update_inode_force_wcc_locked() calls into
>>>>>>>>>> nfs_inode_attrs_need_update() it determines that it doesn't need to
>>>>>>>>>> update them (even though the size and the time have changed). so it
>>>>>>>>>> doesn't call nfs_wcc_update_inode() so the inode->i_version doesn't
>>>>>>>>>> get set to the ctime that was received in the 2nd reply.
>>>>>>>>>>
>>>>>>>>>> On the 3rd reply
>>>>>>>>>> fattr->gencount=37 nfsi->gencount=36 generation_counter=37
>>>>>>>>>>
>>>>>>>>>> It leads to nfs_inode_attrs_need_update() returns 1 and in the
>>>>>>>>>> nfs_update_inode() the difference in the ctimes leads to invalidation.
>>>>>>>>>> fattr->gencount was update from nfs_writeback_update_node() ->
>>>>>>>>>> nfs_post_op_update_inode_force_wcc() calling nfs_fattr_set_barrier().
>>>>>>>>>>
>>>>>>>>>> I'm not sure what appropriate values for "gencount" should have been.
>>>>>>>>>> But if the check for nfs_ctime_need_update() was still there in
>>>>>>>>>> nfs_inode_attrs_need_update() then the 2nd reply would have
>>>>>>>>>> appropriately updated the i_version and not lead to invalidation.
>>>>>>>>>
>>>>>>>>> Would like to add that this problem is not seen against the Linux
>>>>>>>>> server because it doesn't send "before" attributes. So code doesn't
>>>>>>>>> set the "pre_change_attr" which later doesn't make what's stored in
>>>>>>>>> inode->i_version.
>>>>>>>>>
>>>>>>>>> The problem also not seen for v4 because pre_change_attr is not gotten
>>>>>>>>> from the "before" attributes but instead from the previous value in
>>>>>>>>> inode->i_version which is then compared to the itself.
>>>>>>>>>
>>>>>>>>> If reverting the problematic commit is not the solution, then how
>>>>>>>>> about ignoring the "before" ctime attributes sent by the server. This
>>>>>>>>> also helps with the out-of-order RPCs.
>>>>>>>>
>>>>>>>> Why bother doing that on the client? These attributes aren't mandatory
>>>>>>>> to send...
>>>>>>>>
>>>>>>>
>>>>>>> Leads to poor client performances. Every large enough read invalidates
>>>>>>> the cache so all the reads go to the server always.
>>>>>>
>>>>>> I'm saying why not just turn off the WCC functionality on the server then.
>>>>>
>>>>> One reasoning could be that providing cache consistency is client's
>>>>> responsibility. Server only provides needed information.
>>>>
>>>> Sure, but the server is the single point of control for all clients.
>>>
>>> What about other client implementations that might use before attributes?
>>>
>>>>> While I can see that handling out-of-order RPCs might not be worth it
>>>>> because hopefully it doesn't happen often but handling in order RPCs
>>>>> and always invalidating the cache is a bug.
>>>>
>>>> We don't invalidate on in-order RPCs.
>>>
>>> Yes we do and that was the point of my initial post. The commit
>>> introduced a regression.
>>
>> No we don't. If the RPC replies were received in the order in which
>> they were processed on the server, then the WCC information would
>> match what is currently in the client cache. Your patch turns off WCC
>> processing on the client in order to avoid that ordering problem by
>> having the client fill in WCC info that matches what is in its cache.
>
> The RPCs are returned in order.
>
> The problem is when the 2nd reply is gotten the attributes are not
> updated. When the 3rd reply is processed it finds the attributes no
> longer match.
>
> The attributes should have been updated. They would have been updated
> if the patch was still present.
>
> Enabling the check lead to a problem Chuck reported. I'm reporting
> that disabling it also leads to a problem.
>
> My proposal to turn off WCC was in attempt to solve the problem by
> having something that also solves Chuck problem.

Here's an annotated debugging info showing that attributes are not
being updated due to barriers:

Please look for (***)  but it shows that
gencounts are initialized for each of the 3 outgoing writes.
when 1st reply is processed the fattr->gencount is less than inode's
so the attributes are then updated.
then the nfs_update_inode() bumps the inode's gencount to the next value. WHY??
because the counter is bumped now when the 2nd reply is gotten the
fattr->gencount is now less and attributes are not update.
Now inode has outdated attributes!

Then when 3rd reply is processed it finds mismatching attributes and
invalidates the cache.


Apr  1 15:14:42 compute kernel: AGLO: nfs_fattr_init initializing
fattr=ffff88000a320f70 gencount=33

Apr  1 15:14:42 compute kernel: NFS: initiated pgio call (req
0:39/789905590, 4096 bytes @ offset 0)

Apr  1 15:14:42 compute kernel: AGLO: nfs_fattr_init initializing
fattr=ffff88000a3212f0 gencount=34

Apr  1 15:14:42 compute kernel: NFS: initiated pgio call (req
0:39/789905590, 4096 bytes @ offset 4096)

Apr  1 15:14:42 compute kernel: AGLO: nfs_fattr_init initializing
fattr=ffff88000a321670 gencount=35

Apr  1 15:14:42 compute kernel: NFS: initiated pgio call (req
0:39/789905590, 2048 bytes @ offset 8192)

Apr  1 15:14:42 compute kernel: AGLO: decode_wcc_attr setting
NFS_ATTR_FATTR_PRECHANGE for attr=ffff88000a320f70

Apr  1 15:14:42 compute kernel: AGLO: decode_wcc_attr setting
pre_change_attr 1567151659683131632 for attr=ffff88000a320f70

Apr  1 15:14:42 compute kernel: NFS: nfs_pgio_result:    44, (status 4096)

**** Apr  1 15:14:42 compute kernel: AGLO:
[nfs_post_op_update_inode_force_wcc_locked+0x37/0x120 [nfs]]
nfs_inode_attrs_need_update result=1 fattr=ffff88000a320f70
fattr->gencount=33 nfsi->gencount=32 generation_count=35

Apr  1 15:14:42 compute kernel: AGLO:
[nfs_refresh_inode_locked+0x48/0x2b0 [nfs]]
nfs_inode_attrs_need_update result=1 fattr=ffff88000a320f70
fattr->gencount=33 nfsi->gencount=32 generation_count=35

Apr  1 15:14:42 compute kernel: NFS: nfs_update_inode(0:39/789905590
fh_crc=0x1699a74d ct=1 info=0x7febf)

Apr  1 15:14:42 compute kernel: AGLO: nfs_wcc_update_inode
i_version=1567151659683131632 pre_change_attr=1567151659683131632
prechange=262144 change=131072 fattr=ffff88000a320f70

Apr  1 15:14:42 compute kernel: AGLO: nfs_wcc_update_inode updating
ctime to 1567151659694027632

Apr  1 15:14:42 compute kernel: AGLO: nfs_update_inode inode
version=1567151659694027632 and attr=1567151659694027632

**** Apr  1 15:14:42 compute kernel: AGLO: nfs_update_inode updating
inode gencount = 36

Apr  1 15:14:42 compute kernel: AGLO: nfs3_write_done
version=1567151659694027632 inode attr = 10240 received attr 4096

Apr  1 15:14:42 compute kernel: AGLO: decode_wcc_attr setting
NFS_ATTR_FATTR_PRECHANGE for attr=ffff88000a3212f0

Apr  1 15:14:42 compute kernel: AGLO: decode_wcc_attr setting
pre_change_attr 1567151659694027632 for attr=ffff88000a3212f0

Apr  1 15:14:42 compute kernel: NFS: nfs_pgio_result:    45, (status 4096)

**** Apr  1 15:14:42 compute kernel: AGLO:
[nfs_post_op_update_inode_force_wcc_locked+0x37/0x120 [nfs]]
nfs_inode_attrs_need_update result=0 fattr=ffff88000a3212f0
fattr->gencount=34 nfsi->gencount=36 generation_count=36

Apr  1 15:14:42 compute kernel: AGLO:
[nfs_refresh_inode_locked+0x48/0x2b0 [nfs]]
nfs_inode_attrs_need_update result=0 fattr=ffff88000a3212f0
fattr->gencount=34 nfsi->gencount=36 generation_count=36
