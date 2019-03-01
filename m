Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8829DC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 05:08:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 50CD720842
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 05:08:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725913AbfCAFIq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 00:08:46 -0500
Received: from out30-43.freemail.mail.aliyun.com ([115.124.30.43]:49186 "EHLO
        out30-43.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725287AbfCAFIq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 00:08:46 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TLdYp3F_1551416923;
Received: from ali-186590e05fa3.local(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TLdYp3F_1551416923)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 01 Mar 2019 13:08:44 +0800
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Joseph Qi <joseph.qi@linux.alibaba.com>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
From:   Jiufei Xue <jiufei.xue@linux.alibaba.com>
Message-ID: <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
Date:   Fri, 1 Mar 2019 13:08:43 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

On 2019/3/1 上午6:26, Olga Kornievskaia wrote:
> On Thu, Feb 28, 2019 at 5:11 AM Jiufei Xue <jiufei.xue@linux.alibaba.com> wrote:
>>
>> Hi,
>>
>> when I tested xfstests/generic/323 with NFSv4.1 and v4.2, the task
>> changed to zombie occasionally while a thread is hanging with the
>> following stack:
>>
>> [<0>] rpc_wait_bit_killable+0x1e/0xa0 [sunrpc]
>> [<0>] nfs4_do_close+0x21b/0x2c0 [nfsv4]
>> [<0>] __put_nfs_open_context+0xa2/0x110 [nfs]
>> [<0>] nfs_file_release+0x35/0x50 [nfs]
>> [<0>] __fput+0xa2/0x1c0
>> [<0>] task_work_run+0x82/0xa0
>> [<0>] do_exit+0x2ac/0xc20
>> [<0>] do_group_exit+0x39/0xa0
>> [<0>] get_signal+0x1ce/0x5d0
>> [<0>] do_signal+0x36/0x620
>> [<0>] exit_to_usermode_loop+0x5e/0xc2
>> [<0>] do_syscall_64+0x16c/0x190
>> [<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
>> [<0>] 0xffffffffffffffff
>>
>> Since commit 12f275cdd163(NFSv4: Retry CLOSE and DELEGRETURN on
>> NFS4ERR_OLD_STATEID), the client will retry to close the file when
>> stateid generation number in client is lower than server.
>>
>> The original intention of this commit is retrying the operation while
>> racing with an OPEN. However, in this case the stateid generation remains
>> mismatch forever.
>>
>> Any suggestions?
> 
> Can you include a network trace of the failure? Is it possible that
> the server has crashed on reply to the close and that's why the task
> is hung? What server are you testing against?
>
I am testing the local server, the testcase is attached below.

# uname -r
5.0.0-rc8

# cat /etc/exports
/mnt/vdd *(rw,no_subtree_check,no_root_squash)

# cat test.sh
mount /dev/vdd /mnt/vdd
systemctl start nfs
mount -t nfs -o rw,relatime,vers=4.1 127.0.0.1:/mnt/vdd /mnt/nfsscratch

for ((i=0;i<10000;i++))
do
        echo "loop $i started"
        /usr/local/xfstests/src/aio-dio-regress/aio-last-ref-held-by-io 1 100 /mnt/nfsscratch/aio-testfile
	sleep 5
done

The command aio-last-ref-held-by-io from xfstests will spawn 100 threads. Each thread
repeated doing open/io_submit/close/io_getevents/io_destroy until the parent exist
because of timeout.


Here is the log when the task hung.

[10841.121523] nfs4_close_prepare: begin!
[10841.121526] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=10
[10841.121528] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[10841.121530] nfs4_close_prepare: done!
[10841.121536] encode_sequence: sessionid=1551405749:3822331530:1:0 seqid=59495845 slotid=0 max_slotid=0 cache_this=1
[10841.121583] nfsd_dispatch: vers 4 proc 1
[10841.121588] __find_in_sessionid_hashtbl: 1551405749:3822331530:1:0
[10841.121590] nfsd4_sequence: slotid 0
[10841.121592] check_slot_seqid enter. seqid 59495845 slot_seqid 59495844
[10841.121596] nfsd: fh_verify(28: 01060001 0c66c6db d74ea4c9 61e12d9e c03beba6 0000000b)
[10841.121607] nfsd: fh_verify(28: 01060001 0c66c6db d74ea4c9 61e12d9e c03beba6 0000000b)
[10841.121613] NFSD: nfsd4_close on file aio-testfile
[10841.121615] NFSD: nfs4_preprocess_seqid_op: seqid=0 stateid = (5c7892b5/e3d4268a/000ab905/0000746b)
[10841.121619] nfsv4 compound returned 10024
[10841.121621] --> nfsd4_store_cache_entry slot 00000000f540ddd9
[10841.121625] renewing client (clientid 5c7892b5/e3d4268a)
[10841.122526] decode_attr_type: type=00
......
[10841.122558] nfs4_close_done: begin!
[10841.122561] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=10
[10841.122564] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[10841.122566] nfs4_free_slot: slotid 1 highest_used_slotid 0
[10841.122568] nfs41_sequence_process: Error 0 free the slot
[10841.122571] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[10841.122575] nfs4_close_done: done, ret = 0!
[10841.122584] nfs4_close_prepare: begin!
......
Client keep retry the CLOSE.

> I have seen trace where close would get ERR_OLD_STATEID and would
> still retry with the same open state until it got a reply to the OPEN
> which changed the state and when the client received reply to that,
> it'll retry the CLOSE with the updated stateid.
>

Yes, you are right. I have also noticed that. But what happened if the
OPEN task exit receiving a signal? How can a client update the stateid?

Thanks,
Jiufei
