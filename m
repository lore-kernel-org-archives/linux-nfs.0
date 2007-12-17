From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 01/38] svc: Add an svc transport class
Date: Mon, 17 Dec 2007 03:40:41 -0600
Message-ID: <C38BA039.233C0%tom@opengridcomputing.com>
References: <20071213184506.GA29496@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:8257 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859AbXLQJlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2007 04:41:04 -0500
In-Reply-To: <20071213184506.GA29496@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/13/07 12:45 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> Sorry for joining in a little late....
> 
> On Tue, Dec 11, 2007 at 05:31:54PM -0600, Tom Tucker wrote:
>> +int svc_reg_xprt_class(struct svc_xprt_class *xcl)
> 
> None of the callers appear to check the return value, so this should
> probably be a void return.
>

I don't feel strongly about this, but what I was trying to catch was two
different transports accidentally colliding on the same name. I doubt there
will be a run on new transports, but it would at least fail the module load
with a reasonable error.

>> +{
>> + struct svc_xprt_class *cl;
>> + int res = -EEXIST;
>> +
>> + dprintk("svc: Adding svc transport class '%s'\n",
>> +  xcl->xcl_name);
>> +
>> + INIT_LIST_HEAD(&xcl->xcl_list);
> 
> Unless we care how xcl_list is set in the error case, this is
> unnecessary.
>

I'll leave this and clean up the un-register path as you suggest below.

 
>> + spin_lock(&svc_xprt_class_lock);
>> + list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
>> +  if (xcl == cl)
>> +   goto out;
> 
> Is this even worth checking?  Accidentally registering the identical
> struct svc_xprt_class * seems an unlikely mistake for a transport-class
> coder to make, given that they only need call this function once per
> transport, in the module initialization.  Maybe make this a BUG()?  Or
> check for duplicate xcl_name's if that seems a more likely error?

What I really wanted to check was name == name, not necessarily ptr == ptr.
I should fix this to fail if strcmp(xcl->name, cl->name)==0.

> 
>> + }
>> + list_add_tail(&xcl->xcl_list, &svc_xprt_class_list);
>> + res = 0;
>> +out:
>> + spin_unlock(&svc_xprt_class_lock);
>> + return res;
>> +}
>> +EXPORT_SYMBOL_GPL(svc_reg_xprt_class);
>> +
>> +int svc_unreg_xprt_class(struct svc_xprt_class *xcl)
>> +{
>> + struct svc_xprt_class *cl;
>> + int res = 0;
>> +
>> + dprintk("svc: Removing svc transport class '%s'\n", xcl->xcl_name);
>> +
>> + spin_lock(&svc_xprt_class_lock);
>> + list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
>> +  if (xcl == cl) {
>> +   list_del_init(&cl->xcl_list);
>> +   goto out;
>> +  }
>> + }
>> + res = -ENOENT;
> 
> Again, nobody checks this error return, and it seems like an unlikely
> programmer error anyway. If we really need the check I'd be inclined
> just to ditche the for loop and BUG_ON(list_empty(&cl->xcl_list)), which
> will catch double-unregistrations (thanks to the list_del_init()).
>

Yeah, the loop is dumb. I agree with your error assessment, how about if I
change the return type to void and list_del_init(...) sans loop.


>> + out:
>> + spin_unlock(&svc_xprt_class_lock);
>> + return res;
>> +}
>> +EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
>> +
>> +/*
>> + * Called by transport drivers to initialize the transport independent
>> + * portion of the transport instance.
>> + */
>> +void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
>> +{
>> + memset(xprt, 0, sizeof(*xprt));
>> + xprt->xpt_class = xcl;
>> + xprt->xpt_ops = xcl->xcl_ops;
>> +}
>> +EXPORT_SYMBOL_GPL(svc_xprt_init);
> 
> Seems fine otherwise.
> 
> --b.


