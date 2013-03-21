Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:19988 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751346Ab3CUBPH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 21:15:07 -0400
Message-ID: <514A5F32.2020603@cn.fujitsu.com>
Date: Thu, 21 Mar 2013 09:15:30 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-block: removing DM device maybe cause oops when
 call dev_remove
References: <51496CC5.7040400@cn.fujitsu.com> <1363807637.4790.63.camel@leira.trondhjem.org>
In-Reply-To: <1363807637.4790.63.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond 写道:
> On Wed, 2013-03-20 at 16:01 +0800, fanchaoting wrote:
>> when pnfs block using device mapper,if umounting later,it maybe
>> cause oops. we apply "1 + sizeof(bl_umount_request)" memory for
>> msg->data, the memory maybe overflow when we do "memcpy(&dataptr
>> [sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request))",
>> because the size of bl_msg is more than 1 byte.
>>
>>    Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
>>
>> ---
>>  fs/nfs/blocklayout/blocklayoutdm.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
>> index 737d839..8df9afa 100644
>> --- a/fs/nfs/blocklayout/blocklayoutdm.c
>> +++ b/fs/nfs/blocklayout/blocklayoutdm.c
>> @@ -55,7 +55,7 @@ static void dev_remove(struct net *net, dev_t dev)
>>
>>         bl_pipe_msg.bl_wq = &nn->bl_wq;
>>         memset(msg, 0, sizeof(*msg));
>> -       msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
>> +       msg->data = kzalloc(sizeof(bl_msg) + sizeof(bl_umount_request), GFP_NOFS);
>>         if (!msg->data)
>>                 goto out;
>>
> 
> Why not just move the calculation of msg->len, and then use msg->len in
> the above allocation?
> 

yes, you are right, thanks for reviewing, here is the change patch.


when pnfs block using device mapper,if umounting later,it maybe
cause oops. we apply "1 + sizeof(bl_umount_request)" memory for
msg->data, the memory maybe overflow when we do "memcpy(&dataptr
[sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request))",
because the size of bl_msg is more than 1 byte.

Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
Reviewed-by: Trond Myklebust <Trond.Myklebust@netapp.com>

---
 fs/nfs/blocklayout/blocklayoutdm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 737d839..6fc7b5c 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -55,7 +55,8 @@ static void dev_remove(struct net *net, dev_t dev)

        bl_pipe_msg.bl_wq = &nn->bl_wq;
        memset(msg, 0, sizeof(*msg));
-       msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
+       msg->len = sizeof(bl_msg) + bl_msg.totallen;
+       msg->data = kzalloc(msg->len, GFP_NOFS);
        if (!msg->data)
                goto out;

@@ -66,7 +67,6 @@ static void dev_remove(struct net *net, dev_t dev)
        memcpy(msg->data, &bl_msg, sizeof(bl_msg));
        dataptr = (uint8_t *) msg->data;
        memcpy(&dataptr[sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request));
-       msg->len = sizeof(bl_msg) + bl_msg.totallen;

        add_wait_queue(&nn->bl_wq, &wq);
        if (rpc_queue_upcall(nn->bl_device_pipe, msg) < 0) {
--
1.7.1




