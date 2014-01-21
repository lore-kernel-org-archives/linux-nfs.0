Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:53022 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbaAUPEV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 10:04:21 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so11048258igb.3
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jan 2014 07:04:21 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/2] nfs4: fix discover_server_trunking use after free
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <D87D3ADC-94A0-438D-AADD-4139C70AE3B3@primarydata.com>
Date: Tue, 21 Jan 2014 10:04:20 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <2E51C118-9C64-4864-88C8-5586E5DB5A88@primarydata.com>
References: <1390189537-9666-1-git-send-email-dros@primarydata.com> <D87D3ADC-94A0-438D-AADD-4139C70AE3B3@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 20, 2014, at 6:32 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 19, 2014, at 20:45, Weston Andros Adamson <dros@primarydata.com> wrote:
> 
>> If clp is new (cl_count = 1) and it matches another client in
>> nfs4_discover_server_trunking, the nfs_put_client will free clp before
>> ->cl_preserve_clid is set.
>> 
>> Cc: stable@vger.kernel.org # 3.7+
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>> fs/nfs/nfs4client.c | 7 ++++---
>> 1 file changed, 4 insertions(+), 3 deletions(-)
>> 
>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>> index c1b7a80..0f9b772 100644
>> --- a/fs/nfs/nfs4client.c
>> +++ b/fs/nfs/nfs4client.c
>> @@ -414,11 +414,12 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>> 	error = nfs4_discover_server_trunking(clp, &old);
>> 	if (error < 0)
>> 		goto error;
>> -	nfs_put_client(clp);
>> -	if (clp != old) {
>> +
>> +	if (clp != old)
>> 		clp->cl_preserve_clid = true;
>> +	nfs_put_client(clp);
>> +	if (clp != old)
>> 		clp = old;
>> -	}
>> 
> 
> Applied, but I cleaned it up by replacing the last 2 lines with an equivalent ‘return old’…

Cool, I almost posted that, but thought this change was a “cleaner” diff.

-dros

> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

