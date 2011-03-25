Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:49427 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab1CYJi7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 05:38:59 -0400
Received: by pzk9 with SMTP id 9so122137pzk.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2011 02:38:59 -0700 (PDT)
Message-ID: <4D8C62C3.6080901@panasas.com>
Date: Fri, 25 Mar 2011 11:39:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        Fred Isaman <iisaman@netapp.com>, NFS list <linux-nfs@vger.kernel.org>,
        David Black <Black_David@emc.com>, "Rees, James" <rees@umich.edu>
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
References: <AANLkTinBuLxDq5zrxC=-0fS_md5CXTQAS_POsKA9issP@mail.gmail.com>	 <4D8B732F.8020404@panasas.com>	 <1300985305.31106.6.camel@lade.trondhjem.org>	 <4D8B781D.6090007@panasas.com> <1300986948.31106.16.camel@lade.trondhjem.org>
In-Reply-To: <1300986948.31106.16.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-24 19:15, Trond Myklebust wrote:

> On Thu, 2011-03-24 at 18:58 +0200, Benny Halevy wrote:
>> On 2011-03-24 18:48, Trond Myklebust wrote:
>>> On Thu, 2011-03-24 at 18:37 +0200, Benny Halevy wrote:
>>>> On 2011-03-24 15:57, William A. (Andy) Adamson wrote:
>>>>>>> Only whole file layout support means that there is only one IOMODE_RW layout
>>>>>>> segment.
>>>>>>>
>>>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>>>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>>>>>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>>>>>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>>>>>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>>>>>> Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
>>>>>>> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>>>>>>> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>>>>>>> Tested-by: Boaz Harrosh <bharrosh@panasas.com>
>>>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>>> The code in this patch is new and different enough from the one I/we
>>>>>> signed-off originally that they don't make sense here.
>>>>> Hi Benny
>>>>>
>>>>> OK with me
>>>>>
>>>>>>> +             /* references matched in nfs4_layoutcommit_release */
>>>>>>> +             wdata->lseg->pls_lc_cred =
>>>>>>> +                     get_rpccred(wdata->args.context->state->owner->so_cred);
>>>>>>> +             mark_inode_dirty_sync(wdata->inode);
>>>>>>> +             dprintk("%s: Set layoutcommit for inode %lu ",
>>>>>>> +                     __func__, wdata->inode->i_ino);
>>>>>>> +     }
>>>>>>> +     if (end_pos > wdata->lseg->pls_end_pos)
>>>>>>> +             wdata->lseg->pls_end_pos = end_pos;
>>>>>> The end_pos is essentially per inode, why maintain it per lseg?
>>>>>> How do you see this working with multiple lsegs in mind?
>>>>> The end-pos is per lseg, not per inode - each layoutcommit applies to
>>>>> a range of WRITES for a layoutsegment over the LAYOUTCOMMIT range.
>>>>>
>>>>> From Section 18.42.3
>>>>> .  The byte-range being committed is
>>>>>    specified through the byte-range (loca_offset and loca_length).  This
>>>>>    byte-range MUST overlap with one or more existing layouts previously
>>>>>    granted via LAYOUTGET
>>>>>
>>>>>
>>>>>    Also, loca_last_write_offset MUST overlap the range
>>>>>    described by loca_offset and loca_length.
>>>>>
>>>>> For the multiple lseg case: if the lsegs are merged, bookeeping
>>>>> end_pos per lseg just works. If a layoutdriver does not use merged
>>>>> lsegs, then there is a bit of work to do to walk the list of lsegs and
>>>>> determine the final end_pos for a given LAYOUTCOMMIT.  If there are
>>>>> multiple non-contiguous lsegs, each used for WRITEs then multiple
>>>>> LAYOUTCOMMITs will need to be sent, otherwise the LAYOUTCOMMIT
>>>>> byte-range will not overlap as required.
>>>>>
>>>> For the current layout types I believe that the LAYOUTCOMMIT can "merge"
>>>> multiple layout segments into a single LAYOUTCOMMIT, with a byte range
>>>> covering all segments and a last_byte_written offset which is just the maximum.
>>>> Future layout types may need this method though...
>>> Is that safe?
>>>
>>> What if I'm doing blocks and have written layout segment 1 & 3, but not
>>> layout segment 2? I don't want to have the MDS commit layout segment 2,
>>> and make the (lack of) data there visible to future readers.
>>>
>> I'm not the real expert on pnfs-blocks but my interpretation of rfc5663 is that the
>> list of extents in pnfs_block_layoutupdate4 may be sparse (or holey if you'd like).
>> Note that the client may have written just parts of the layout it got in one layout segment.
>> In this case too, you don't want to send multiple LAYOUTCOMMITs for each contiguous
>> area...
> Sure, but my understanding was that RFC5663 supports copy on write files
> and that the actual copying of the block may need to be done by the
> client (see section 2.3.4).
>
> If the new block is still uninitialised when you call LAYOUTCOMMIT, then
> that will corrupt the file if the client then dies before it finishes
> processing segment 2, since the previously valid data blocks are being
> replaced by uninitialised ones (which I presume will convert that
> section into a pre-allocated hole???).
>
The extents that LAYOUTCOMMITted MUST NOT be PNFS_BLOCK_INVALID_DATA,
as noted in 2.3.2:

   The bex_state
   field of each extent in the blu_commit_list MUST be set to
   PNFS_BLOCK_READ_WRITE_DATA.

Benny


