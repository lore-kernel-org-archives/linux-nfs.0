Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:55650 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbaD0IeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Apr 2014 04:34:07 -0400
Message-ID: <535CC0FC.8070403@gmx.de>
Date: Sun, 27 Apr 2014 10:34:04 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Trond Myklebust <trondmy@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fs/nfs/idmap.c: fix a Memory leak for variable desc
References: <1398542157-20159-1-git-send-email-toralf.foerster@gmx.de> <CAABAsM5nm9eRJXF809TPLu5qNeVU0XLPPjtfnji37REQmYHqsQ@mail.gmail.com>
In-Reply-To: <CAABAsM5nm9eRJXF809TPLu5qNeVU0XLPPjtfnji37REQmYHqsQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/27/2014 02:10 AM, Trond Myklebust wrote:
> On Sat, Apr 26, 2014 at 3:55 PM, Toralf Förster <toralf.foerster@gmx.de> wrote:
>> Signed-off-by: Toralf Förster <toralf.foerster@gmx.de>
>> ---
>>  fs/nfs/idmap.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>> index 567983d..8eb4954 100644
>> --- a/fs/nfs/idmap.c
>> +++ b/fs/nfs/idmap.c
>> @@ -272,8 +272,10 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
>>         ssize_t ret;
>>
>>         ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
>> -       if (ret <= 0)
>> +       if (ret <= 0) {
>> +               kfree(desc);
>>                 return ERR_PTR(ret);
>> +       }
>>
>>         rkey = request_key(&key_type_id_resolver, desc, "");
>>         if (IS_ERR(rkey)) {
> 
> Hi Toralf,
> 
> As far as I can tell, the only error that nfs_idmap_get_desc() can
> return is ret==-ENOMEM, in which case desc==NULL.
> It cannot ever return ret==0, either, since the return value,
> 'desclen', has a lower bound of '2'.                                   <-----------------

Ick, that I was missing - sry for the noise.

> Cheers
>   Trond
> 


-- 
Toralf

