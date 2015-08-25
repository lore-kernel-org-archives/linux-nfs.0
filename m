Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:32974 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbbHYQJF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 12:09:05 -0400
Received: by iods203 with SMTP id s203so192374926iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 09:09:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55DC924A.7050702@Netapp.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-5-git-send-email-tao.peng@primarydata.com> <55DC924A.7050702@Netapp.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Wed, 26 Aug 2015 00:08:44 +0800
Message-ID: <CAKVebiW82MCd2C8repUXafZF1PJ6+1g9O=QR1eqvBL=R9PUeKw@mail.gmail.com>
Subject: Re: [PATCH RFC 04/11] nfs42: remove unused declaration
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 12:05 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hi Tao,
>
> On 08/25/2015 11:33 AM, Peng Tao wrote:
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/nfs/nfs42.h | 2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
>> index ff66ae7..814c125 100644
>> --- a/fs/nfs/nfs42.h
>> +++ b/fs/nfs/nfs42.h
>> @@ -17,7 +17,5 @@ int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
>>  loff_t nfs42_proc_llseek(struct file *, loff_t, int);
>>  int nfs42_proc_layoutstats_generic(struct nfs_server *,
>>                                  struct nfs42_layoutstat_data *);
>> -/* nfs4.2xdr.h */
>> -extern struct rpc_procinfo nfs4_2_procedures[];
>
> Same thing here.  Maybe submit both patches together as a cleanup patch series?
>
Will do. Thanks!

Cheers,
Tao
> Thanks,
> Anna
>
>>
>>  #endif /* __LINUX_FS_NFS_NFS4_2_H */
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
