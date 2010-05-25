From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: Re: [PATCH v3] SQUASHME: pnfs: unlock lo_lock before calling
	layoutdriver's setup_layoutcommit
Date: Tue, 25 May 2010 23:26:44 +0800
Message-ID: <AANLkTik8xzvd8vahf_tm-9UyauObg5ES3gmyFOXZy3MJ@mail.gmail.com>
References: <20100525085119.GA7998@vmware> <4BFBD1C0.1040105@panasas.com>
	 <4BFBE146.1060906@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46251 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758691Ab0EYP0p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 11:26:45 -0400
Received: by vws9 with SMTP id 9so3390734vws.19
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 08:26:44 -0700 (PDT)
In-Reply-To: <4BFBE146.1060906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 25, 2010 at 10:40 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> Boaz Harrosh wrote:
>> From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>>
>> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
>> allocation in bl_setup_layoutcommit().
>>
>> The state protected by the lo_lock here is clear now, which is the
>> layout_commit's position and state. .i.e write_begin/end_pos,
>> nfsi->lo_cred, and the call to pnfs_get_layout_stateid.
>
> Yeah, this looks cleaner.
Yes, thanks.
> Tao, can you please test and ack this patch before I merge it?
>
> Thanks!
>
> Benny
>
Ok, I will test it tomorrow morning.
-- 
Tao.
