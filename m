From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v3] SQUASHME: pnfs: unlock lo_lock before calling 	layoutdriver's
 setup_layoutcommit
Date: Thu, 27 May 2010 21:07:36 +0300
Message-ID: <4BFEB4E8.2060102@panasas.com>
References: <20100525085119.GA7998@vmware> <4BFBD1C0.1040105@panasas.com>	 <4BFBE146.1060906@panasas.com>	 <AANLkTik8xzvd8vahf_tm-9UyauObg5ES3gmyFOXZy3MJ@mail.gmail.com> <AANLkTimR9XBYuja0kj_8LEv-F1_9kbHQ97bcYcnTj4tI@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
To: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54658 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753220Ab0E0SHj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:07:39 -0400
In-Reply-To: <AANLkTimR9XBYuja0kj_8LEv-F1_9kbHQ97bcYcnTj4tI-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 26, 2010, 4:15 +0300, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> On Tue, May 25, 2010 at 11:26 PM, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
>> On Tue, May 25, 2010 at 10:40 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>>> Boaz Harrosh wrote:
>>>> From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>>>>
>>>> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
>>>> allocation in bl_setup_layoutcommit().
>>>>
>>>> The state protected by the lo_lock here is clear now, which is the
>>>> layout_commit's position and state. .i.e write_begin/end_pos,
>>>> nfsi->lo_cred, and the call to pnfs_get_layout_stateid.
>>>
>>> Yeah, this looks cleaner.
>> Yes, thanks.
>>> Tao, can you please test and ack this patch before I merge it?
>>>
>>> Thanks!
>>>
>>> Benny
> I have tested it, it is OK.
> 
> Tao
>>

Great, Thanks!
I merged this patch for both the 2.6.34 pnfs-all-latest tree
and pnfs-all-2.6.33.

Benny
