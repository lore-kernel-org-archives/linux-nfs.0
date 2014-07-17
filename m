Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:39210 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932364AbaGQNYS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 09:24:18 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so3142500pdj.15
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 06:24:17 -0700 (PDT)
Message-ID: <53C7CE7D.9070904@gmail.com>
Date: Thu, 17 Jul 2014 21:24:13 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: handle failure to find backchannel
References: <20140711211609.GA13656@fieldses.org> <53C13FE9.3080503@gmail.com> <20140716220526.GG2397@fieldses.org>
In-Reply-To: <20140716220526.GG2397@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/17/2014 06:05, J. Bruce Fields wrote:
> On Sat, Jul 12, 2014 at 10:02:17PM +0800, Kinglong Mee wrote:
>> On 7/12/2014 05:16, J. Bruce Fields wrote:
>>> The local variable "ses" will be left NULL here in the case we fail to
>>> find a connection.  Spotted by a coverity scan.
>>>     
>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>
>>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>>> index 2c73cae9899d..fe22cd5c42d3 100644
>>> --- a/fs/nfsd/nfs4callback.c
>>> +++ b/fs/nfsd/nfs4callback.c
>>> @@ -1001,14 +1001,18 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
>>>  	}
>>>  	spin_unlock(&clp->cl_lock);
>>>  
>>> +	if (!c)
>>> +		goto out_no_connection;
>>
>> Setting err to -EINVAL maybe better.
>> Otherwise, nfsd4_mark_cb_down will be called with err == 0.
>>
>>>  	err = setup_callback_client(clp, &conn, ses);
>>
>> setup_callback_client also return -EINVAL when ses == NULL with conn.cb_xprt == NULL.
> 
> Thanks, yes, after looking over this carefully I don't believe we can
> call setup_callback_client with ses NULL but conn->cb_xprt non-NULL, so
> this is just a false positive from coverity.

ses and conn->cb_xprt will be set in the same condition before
calling setup_callback_client,

 996         c = __nfsd4_find_backchannel(clp);
 997         if (c) {
 998                 svc_xprt_get(c->cn_xprt);
 999                 conn.cb_xprt = c->cn_xprt;
1000                 ses = c->cn_session;
1001         }
1002         spin_unlock(&clp->cl_lock);
1003
1004         err = setup_callback_client(clp, &conn, ses);

ses and conn->cb_xprt will be NULL or non-NULL in the same time,
so that, call setup_calback_client with ses NULL but conn->cb_xprt non-NULL will not appear.

thanks,
Kinglong Mee

>>> -	if (err) {
>>> -		nfsd4_mark_cb_down(clp, err);
>>> -		return;
>>> -	}
>>> +	if (err)
>>> +		goto out_no_connection;
>>>  	/* Yay, the callback channel's back! Restart any callbacks: */
>>>  	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
>>>  		run_nfsd4_cb(cb);
>>> +	return;
>>> +out_no_connection:
>>> +	nfsd4_mark_cb_down(clp, err);
>>> +	return;
>>>  }
>>>  
>>>  static void nfsd4_do_callback_rpc(struct work_struct *w)
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
> 
