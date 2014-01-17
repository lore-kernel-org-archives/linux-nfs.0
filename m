Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f54.google.com ([74.125.82.54]:41835 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbaAQNFo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 08:05:44 -0500
MIME-Version: 1.0
In-Reply-To: <C6749CD6-1F47-42C5-8E27-A11167BF69E4@primarydata.com>
References: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
 <1389638751-16173-1-git-send-email-trond.myklebust@primarydata.com>
 <1389638751-16173-2-git-send-email-trond.myklebust@primarydata.com>
 <CA+a=Yy6uf73Y=F5-Jp+2VrzMmbTYZXqDaEj-EHX335M3ZCvEZA@mail.gmail.com> <C6749CD6-1F47-42C5-8E27-A11167BF69E4@primarydata.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 17 Jan 2014 21:05:22 +0800
Message-ID: <CA+a=Yy74dnd8a=uvyHgcLkp=54Qi-42N_7X=iJPQR5=b5oNA7Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] NFSv4.1: Fix a race in nfs4_write_inode
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: shaobingqing <shaobingqing@bwstor.com.cn>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 17, 2014 at 1:11 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> On Jan 16, 2014, at 10:49, Peng Tao <bergwolf@gmail.com> wrote:
>> On Tue, Jan 14, 2014 at 2:45 AM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
>>> @@ -1881,43 +1887,37 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>>>        struct nfs4_layoutcommit_data *data;
>>>        struct nfs_inode *nfsi = NFS_I(inode);
>>>        loff_t end_pos;
>>> -       int status = 0;
>>> +       int status;
>>>
>>> -       dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
>>> -
>>> -       if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
>>> +       if (!pnfs_layoutcommit_outstanding(inode))
>> This might be a problem. If nfsi->flags has !NFS_INO_LAYOUTCOMMIT and
>> NFS_INO_LAYOUTCOMMITTING, client cannot issue a new layoutcommit after
>> the inflight one finishes. It might not be an issue for file layout as
>> long as we only use layoutcommit to update time, but it can cause data
>> corruption for block layout.
>
> I don’t understand.
>
> With the new patch, if _either_ NFS_INO_LAYOUTCOMMIT or NFS_INO_LAYOUTCOMMITTING are set, then the client will wait until NFS_INO_LAYOUTCOMMITTING can be locked, it will test for NFS_INO_LAYOUTCOMMIT, and then either issue a new layout commit or exit. How can that cause new breakage for blocks?
>
ah, sorry, I read the old code as your patch... yeah, so you actually
fixed the issue instead of introducing it.

> The only issues that I’m aware of with the blocks layout and LAYOUTCOMMIT today are:
> 1. encode_pnfs_block_layoutupdate() runs out of XDR buffer space after 4-5 iterations in the list_for_each_entry_safe() loop. That is because nobody has yet added support for preallocating a page buffer to store the (potentially very large) array of extents. BTW: that array looks like a perfect candidate for xdr_encode_array2() if we could teach the latter about xdr_stream...
This can also be fixed by limiting the number of extents allowed to be
sent in one single layoutcommit.

> 2. the blocks layout also needs to be able handle the case where the list of extents is so large that a single LAYOUTCOMMIT is not sufficient. There is no reason why it should not be able to send multiple LAYOUTCOMMIT rpc calls when the size exceeds the session forward channel's negotiated max_rqst_sz.
>
You are absolutely right.

Thanks,
Tao
