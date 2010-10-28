Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:49498 "HELO
	exprod5og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751951Ab0J1OOR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 10:14:17 -0400
Message-ID: <4CC98534.40907@panasas.com>
Date: Thu, 28 Oct 2010 16:14:12 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: wharms@bfs.de, Dan Carpenter <error27@gmail.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfs: check kmalloc() return
References: <20101028044403.GV6062@bicker>  <4CC92338.7070304@bfs.de> <1288273273.3194.16.camel@heimdal.trondhjem.org>
In-Reply-To: <1288273273.3194.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-28 15:41, Trond Myklebust wrote:
> On Thu, 2010-10-28 at 09:16 +0200, walter harms wrote:
>>
>> Dan Carpenter schrieb:
>>> The decode_and_add_ds() should return NULL on failure.
>>>
>>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>>>
>>> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
>>> index 51fe64a..098113c 100644
>>> --- a/fs/nfs/nfs4filelayoutdev.c
>>> +++ b/fs/nfs/nfs4filelayoutdev.c
>>> @@ -219,6 +219,8 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
>>>  		goto out_err;
>>>  	}
>>>  	buf = kmalloc(rlen + 1, GFP_KERNEL);
>>> +	if (!buf)
>>> +		goto out_err;
>>>  	buf[rlen] = '\0';
>>>  	memcpy(buf, r_addr, rlen);
>>>  
>>
>> it seems that r_addr is a string, then kstdup() is emulated here.
>>
>> re,
>>  wh
> 
> Not quite. kstrdup() requires that the argument be a NUL-terminated
> string. The above code doesn't.

Right.  kmemdup is the right one.

Benny

> 
> Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
