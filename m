Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:50911 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaGBIkt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2014 04:40:49 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so11588726pdi.32
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 01:40:48 -0700 (PDT)
Message-ID: <53B3C56F.20406@gmail.com>
Date: Wed, 02 Jul 2014 16:40:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Avi Kivity <avi@cloudius-systems.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: fix nfs4d readlink truncated packet
References: <1403792592-1517-1-git-send-email-avi@cloudius-systems.com> <53B2999C.6090401@cloudius-systems.com>
In-Reply-To: <53B2999C.6090401@cloudius-systems.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 7/1/2014 19:21, Avi Kivity wrote:
> On 06/26/2014 05:23 PM, Avi Kivity wrote:
>> XDR requires 4-byte alignment; nfs4d READLINK reply writes out the padding,
>> but truncates the packet to the padding-less size.
>>
>> Fix by taking the padding into consideration when truncating the packet.
>>
> 
> Ping.  I should have mentioned that without this, readlink() returns an I/O error on the client.

Yes, I got
[root@localhost ~]# ll /mnt/
ls: cannot read symbolic link /mnt/test: Input/output error
total 4
-rw-r--r--. 1 root root  0 Jun 14 01:21 123456
lrwxrwxrwx. 1 root root  6 Jul  2 03:33 test
drwxr-xr-x. 1 root root  0 Jul  2 23:50 tmp
drwxr-xr-x. 1 root root 60 Jul  2 23:44 tree
[root@localhost ~]# 

It's introduced by commit 476a7b1f4b2c (nfsd4: don't treat readlink like a zero-copy operation).

> 
>> Signed-off-by: Avi Kivity <avi@cloudius-systems.com>
>> ---
>>   fs/nfsd/nfs4xdr.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 83baf2b..cba93ea 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -3267,7 +3267,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>>         wire_count = htonl(maxcount);
>>       write_bytes_to_xdr_buf(xdr->buf, length_offset, &wire_count, 4);
>> -    xdr_truncate_encode(xdr, length_offset + 4 + maxcount);
>> +    xdr_truncate_encode(xdr, length_offset + 4 + ALIGN(maxcount, 4));

NFSD uses (XDR_QUADLEN(maxcount) << 2)) usually.
Anyway, it's a nice fix.

Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee
