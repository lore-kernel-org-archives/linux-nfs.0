Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:40771 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640AbaAFWkG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 17:40:06 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so18664023ieb.25
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 14:40:05 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140106184926.GC31764@fieldses.org>
Date: Mon, 6 Jan 2014 17:40:03 -0500
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com>
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2014, at 13:49, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
>> xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
>> xprt_create_transport should not kstrdup servername for it.
>> Otherwise, those memory for servername will be leaked.
> 
> OK.  Applying to my tree if Trond has no objection.

Actually. Why do we go through all this code at all if xs_setup_bc_tcp() returns args->bc_xprt->xpt_bc_xprt? I’m assuming that is the only case where xprt->servername != NULL, right?

For instance, won’t calling INIT_WORK() be a source of problems?

> 
> --b.
> 
>> 
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>> net/sunrpc/xprt.c | 6 +++++-
>> 1 file changed, 5 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> index ddd198e..6fa966f 100644
>> --- a/net/sunrpc/xprt.c
>> +++ b/net/sunrpc/xprt.c
>> @@ -1339,7 +1339,11 @@ found:
>> 		xprt_destroy(xprt);
>> 		return ERR_PTR(-EINVAL);
>> 	}
>> -	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
>> +
>> +	/* servername may not be NULL for tcp NFSv4.1 backchannel */
>> +	if (xprt->servername == NULL)
>> +		xprt->servername = kstrdup(args->servername, GFP_KERNEL);
>> +
>> 	if (xprt->servername == NULL) {
>> 		xprt_destroy(xprt);
>> 		return ERR_PTR(-ENOMEM);
>> -- 
>> 1.8.4.2

