From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 30/38] svc: Move common create logic to common code
Date: Mon, 17 Dec 2007 09:27:45 -0600
Message-ID: <C38BF191.23487%tom@opengridcomputing.com>
References: <20071214231913.GK23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:7920 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758326AbXLQP2H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2007 10:28:07 -0500
In-Reply-To: <20071214231913.GK23121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/14/07 5:19 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 11, 2007 at 05:33:00PM -0600, Tom Tucker wrote:
>> 
>> Move the code that adds a transport instance to the sv_tempsocks and
>> sv_permsocks lists out of the transport specific functions and into core
>> logic. 
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> ---
>> 
>>  net/sunrpc/svc_xprt.c |    9 ++++++++-
>>  net/sunrpc/svcsock.c  |   39 +++++++++++++++++++--------------------
>>  2 files changed, 27 insertions(+), 21 deletions(-)
>> 
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index d0cbfe0..924df63 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -145,8 +145,15 @@ int svc_create_xprt(struct svc_serv *serv, char
>> *xprt_name, unsigned short port,
>> if (IS_ERR(newxprt)) {
>> module_put(xcl->xcl_owner);
>> ret = PTR_ERR(newxprt);
>> -    } else
>> +    } else {
>> +     clear_bit(XPT_TEMP,
>> +        &newxprt->xpt_flags);
>> +     spin_lock_bh(&serv->sv_lock);
>> +     list_add(&newxprt->xpt_list,
>> +       &serv->sv_permsocks);
>> +     spin_unlock_bh(&serv->sv_lock);
>> ret = svc_xprt_local_port(newxprt);
>> +    }
>> }
>> goto out;
>> }
> 
> The nesting here is getting kind of deep.
> 
> A bit more idiomatic for kernel code would be (untested) something like:
> 
> list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
> struct svc_xprt *newxprt;
> 
> if (strcmp(xprt_name, xcl->xcl_name) != 0)
> continue;
> spin_unlock(&svc_xprt_class_lock);
> if (!try_module_get(xcl->xcl_owner))
> goto out;
> # (assuming that's the right order)
> newxprt = xcl->xcl_ops->xpo_create (serv,
> (struct sockaddr *)&sin, sizeof(sin), flags);
> if (IS_ERR(newxprt)) {
> module_put(xcl->xcl_owner);
> ret = PTR_ERR(newxprt);
> goto out;
> }
> clear_bit(XPT_TEMP, &newxprt->xpt_flags);
> spin_lock_bh(&serv->sv_lock);
> list_add(&newxprt->xpt_list, &serv->sv_permsocks);
> spin_unlock_bh(&serv->sv_lock);
> ret = svc_xprt_local_port(newxprt);
> goto out;
> }
> 
> At least to my eyes, that also makes it a lot easier to see what the
> important (succesful) case is, since that's the code that stays
> unindented all the way to the end.
> 
> I'd also be inclined to replace those "got out"'s by "returns".  I don't
> really see the point of the label when it's leads to something that's
> literally just a return.
> 

Agree. Fixed.

> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


