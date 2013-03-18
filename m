Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:15159 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab3CRKvF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 06:51:05 -0400
Message-ID: <5146F0A6.2090103@cn.fujitsu.com>
Date: Mon, 18 Mar 2013 18:47:02 +0800
From: chenditang <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@netapp.com>
Subject: Re: pnfs: WRITE operation will not send LAYOUTCOMMI OP to MDS if
 use filelayout
References: <5146BE38.2060004@cn.fujitsu.com> <5146D7F6.3010607@tonian.com>
In-Reply-To: <5146D7F6.3010607@tonian.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2013年03月18日 17:01, Benny Halevy 写道:
> On 2013-03-18 09:11, chenditang wrote:
>> In the recent pnfs kernel versions, WRITE operation will not send
>> LAYOUTCOMMI OP to MDS if use filelayout.
> I presume that the file server sets NFL4_UFLG_COMMIT_THRU_MDS
> and that the DS is returning how=FILE_SYNC and that the client
> is implementing the behavior described in  Errata ID: 2751
> http://www.rfc-editor.org/errata_search.php?rfc=5661
>
> Do you have a tcp dump of client, MDS, and DS traffic?
NFL4_UFLG_COMMIT_THRU_MDS is not set, "nfl_util" is 8192 and "commit_through_mds" is 0 to filelayout_decode_layout.

>> In nfs_write_rpcsetup function, the value of the variable 'stable' will
>> always be NFS_FILE_SYNC(ncommit is 0). so NFS_INO_LAYOUTCOMMIT
>> flag will not be set.
> What's the value of the "how" arg to nfs_write_rpcsetup that you see?
> At any rate, if you look at filelayout_set_layoutcommit, it will not
> call pnfs_set_layoutcommit in the following cases:
>
>          if (FILELAYOUT_LSEG(hdr->lseg)->commit_through_mds ||
>              wdata->res.verf->committed == NFS_FILE_SYNC)
>                  return;
"how" is 32, and "cinfo->mds->ncommit" is 0. pnfs_set_layoutcommit has 
not beeb called.
I think "cinfo->mds->ncommit" can not be used here.

I dump the stack, and the initial value of "ncommit" is 0, then it to be 
used in nfs_write_rpcsetup function,
but "ncommit++" in nfs_writeback_release_common function(if 
NFS_FILE_SYNC is not set).

static const struct rpc_call_ops nfs_write_common_ops = {
.rpc_call_prepare = nfs_write_prepare,
.rpc_call_done = nfs_writeback_done_common,
.rpc_release = nfs_writeback_release_common,
};

The code processes:
step1: init_once --> nfsi->commit_info.ncommit = 0;
setp2: nfs_flush_one --> nfs_write_rpcsetup
setp3: nfs_writeback_done --> nfs_writeback_done --> 
filelayout_write_done_cb --> filelayout_set_layoutcommit
setp4: nfs_writeback_release_common--> ...-->nfs_write_completion --> 
.... --> cinfo->mds->ncommit++;
>
>
> Benny
>
>> The value of the variable ncommit' will be ++ in the later process
>> (nfs_writeback_release_common function).
>>
>>
>> Thanks!
>>



