From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 33/40] pnfs-submit wave3 remove CONFIG_NFS_V4 and V4_1
 from nfs_read_data
Date: Wed, 9 Feb 2011 11:11:53 -0500
Message-ID: <AANLkTinp+6vOLKt6hhkQ04mdcK=HHhwBr7GgCBw9Gjnt@mail.gmail.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
	<1296855242-2592-2-git-send-email-andros@netapp.com>
	<1296855242-2592-3-git-send-email-andros@netapp.com>
	<1296855242-2592-4-git-send-email-andros@netapp.com>
	<1296855242-2592-5-git-send-email-andros@netapp.com>
	<1296855242-2592-6-git-send-email-andros@netapp.com>
	<1296855242-2592-7-git-send-email-andros@netapp.com>
	<1296855242-2592-8-git-send-email-andros@netapp.com>
	<1296855242-2592-9-git-send-email-andros@netapp.com>
	<1296855242-2592-10-git-send-email-andros@netapp.com>
	<1296855242-2592-11-git-send-email-andros@netapp.com>
	<1296855242-2592-12-git-send-email-andros@netapp.com>
	<1296855242-2592-13-git-send-email-andros@netapp.com>
	<1296855242-2592-14-git-send-email-andros@netapp.com>
	<1296855242-2592-15-git-send-email-andros@netapp.com>
	<1296855242-2592-16-git-send-email-andros@netapp.com>
	<1296855242-2592-17-git-send-email-andros@netapp.com>
	<1296855242-2592-18-git-send-email-andros@netapp.com>
	<1296855242-2592-19-git-send-email-andros@netapp.com>
	<1296855242-2592-20-git-send-email-andros@netapp.com>
	<1296855242-2592-21-git-send-email-andros@netapp.com>
	<1296855242-2592-22-git-send-email-andros@netapp.com>
	<1296855242-2592-23-git-send-email-andros@netapp.com>
	<1296855242-2592-24-git-send-email-andros@netapp.com>
	<1296855242-2592-25-git-send-email-andros@netapp.com>
	<1296855242-2592-26-git-send-email-andros@netapp.com>
	<1296855242-2592-27-git-send-email-andros@netapp.com>
	<1296855242-2592-28-git-send-email-andros@netapp.com>
	<1296855242-2592-29-git-send-email-andros@netapp.com>
	<1296855242-2592-30-git-send-email-andros@netapp.com>
	<1296855242-2592-31-git-send-email-andros@netapp.com>
	<1296855242-2592-32-git-send-email-andros@netapp.com>
	<1296855242-2592-33-git-send-email-andros@netapp.com>
	<1296855242-2592-34-git-send-email-andros@netapp.com>
	<AANLkTin_N0rFNr2KzxZ32bpWWUzwJQ4skLnZNVA=W6FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38910 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab1BIQLy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 11:11:54 -0500
Received: by iyj8 with SMTP id 8so302785iyj.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Feb 2011 08:11:53 -0800 (PST)
In-Reply-To: <AANLkTin_N0rFNr2KzxZ32bpWWUzwJQ4skLnZNVA=W6FQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 8, 2011 at 5:09 PM, Fred Isaman <iisaman@netapp.com> wrote:
> On Fri, Feb 4, 2011 at 4:33 PM,  <andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  include/linux/nfs_xdr.h |   12 ++++--------
>>  1 files changed, 4 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 3b2e488..1222aa9 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -1016,15 +1016,11 @@ struct nfs_read_data {
>>        unsigned int            npages; /* Max length of pagevec */
>>        struct nfs_readargs args;
>>        struct nfs_readres  res;
>> -       struct pnfs_layout_segment *lseg;
>> -       struct nfs_client       *ds_clp;   /* pNFS data server */
>> -#ifdef CONFIG_NFS_V4
>>        unsigned long           timestamp;      /* For lease renewal */
>> -#endif
>> -#if defined(CONFIG_NFS_V4_1)
>> -       const struct rpc_call_ops *call_ops;
>> -       __u64                   orig_offset; /* For filelayout dense stripe */
>> -#endif /* CONFIG_NFS_V4_1 */
>> +       struct pnfs_layout_segment *lseg;
>> +       struct nfs_client       *ds_clp;        /* pNFS data server */
>> +       const struct rpc_call_ops *call_ops;    /* For pNFS recovery to MDS */
>
> The comment is misleading, as it is used for pretty much all file
> layout calls, not just recovery.
> Perhaps rename the field to mds_call_ops and drop the comment?
>
>> +       __u64                   orig_offset;    /* Filelayout dense stripe */
>
> Also here, mds_offset might be a better name.

Good suggestions.

-->Andy

>
> Fred
>
>>        struct page             *page_array[NFS_PAGEVEC_SIZE];
>>  };
>>
>> --
>> 1.6.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
