Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:38194 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab0LPONN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 09:13:13 -0500
Received: by bwz16 with SMTP id 16so3605966bwz.4
        for <linux-nfs@vger.kernel.org>; Thu, 16 Dec 2010 06:13:11 -0800 (PST)
In-Reply-To: <4D0A0A77.9010802@panasas.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
	<1291944177-7819-23-git-send-email-iisaman@netapp.com>
	<4D0A0A77.9010802@panasas.com>
Date: Thu, 16 Dec 2010 09:13:11 -0500
Message-ID: <AANLkTinqnA2Qd68FB=ptoeSxrTd8FD47GezUn_83KtGf@mail.gmail.com>
Subject: Re: [PATCH 22/22] pnfs-submit: Turn off layoutcommits
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 16, 2010 at 7:47 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 12/10/2010 03:22 AM, Fred Isaman wrote:
>> Recent changes to close can delay pending layoutcommit until umount,
>> when the async layoutcommits can come tricklng in after we have destroyed
>> the session.
>
> Then "Recent changes" are broken and should be fixed. It was fine
> before. New broken code is not acceptable.
>
>> Since file does not need them, just turn them off for
>> the moment.  Non-file layouts will probably have to trigger them in
>> some fashion at close.
>>
>
> Rrrr. Are we back to this argument. We stand down win an argument
> and 2 weeks later you are back on it has if we never talked about it.
>
> NO!!! only "coherent clustered filesystems" do not need them. It has
> nothing to do with layout type. A none-clustered aggregated parallel
> filesystem will need them just the same as blocks and objects.
>
> AND THE STD DOES NOT GIVE YOU A CHOICE!!!

You keep saying this, but just repeating it does not convince me.
Could you please take the time to explain *why* they are needed.  A
separate thread in the ietf list would be great.  Because right now,
Andy and I are coding and preparing for submission to Trond under the
assumption that they are possibly a nice optimization, but are never
actually needed for the file layout.

Fred

>
>> A better solution is to just push all the layoutcommit code outside
>> of the pnfs-submit branch.  This is really just a stop gap until code
>> is rearranged to make that easier.
>>
>
> Than all this is not finished. Please keep it in the shops until the
> final solution is presented and we can actually see the new compared
> to the old system. Until then we should keep what worked and was tested.
>
> Boaz
>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/nfs4proc.c |    1 -
>>  1 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 9b15535..224bdfe 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -3098,7 +3098,6 @@ static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_dat
>>  {
>>  #ifdef CONFIG_NFS_V4_1
>>       pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
>> -     pnfs_need_layoutcommit(nfsi, data->args.context);
>>  #endif /* CONFIG_NFS_V4_1 */
>>  }
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
