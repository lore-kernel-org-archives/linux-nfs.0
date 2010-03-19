From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] sm-notify: Send fully-qualified and unqualified mon_names
Date: Fri, 19 Mar 2010 16:03:07 -0400
Message-ID: <4BA3D87B.2030301@RedHat.com>
References: <20100315174453.2586.40876.stgit@localhost.localdomain> <20100315175145.2586.1215.stgit@localhost.localdomain> <4BA0B0A4.6020705@RedHat.com> <4BA0E990.4080206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911Ab0CSUDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Mar 2010 16:03:12 -0400
In-Reply-To: <4BA0E990.4080206@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

My apologizes for the delayed response... 

On 03/17/2010 10:39 AM, Chuck Lever wrote:
> On 03/17/2010 06:36 AM, Steve Dickson wrote:
>>>   /*
>>> - * Successful NOTIFY call. Server returns void, so nothing
>>> - * we need to do here.
>>> + * Successful NOTIFY call. Server returns void.
>>> + *
>>> + * Try sending another SM_NOTIFY with an unqualified "my_name"
>>> + * argument.  Reuse the port number.  If "my_name" is already
>>> + * unqualified, we're done.
>>>    */
>>>   static void
>>>   recv_notify_reply(struct nsm_host *host)
>>>   {
>>> -    xlog(D_GENERAL, "Host %s notified successfully", host->name);
>>> +    char *dot = strchr(host->my_name, '.');
>>>
>>> -    smn_forget_host(host);
>>> +    if (dot != NULL) {
>>> +        *dot = '\0';
>>> +        host->send_next = time(NULL);
>>> +        host->xid = 0;
>>> +        if (host->timeout>= NSM_MAX_TIMEOUT / 4)
>>> +            host->timeout = NSM_MAX_TIMEOUT / 4;
>>> +        insert_host(host);
>> What happens when host->my_name now resolves to host in a
>> different domain? Will this mean we now will be sending SM_NOTIFYs
>> to random hosts?
> 
>> Also, what happens when host->my_name does not resolve to anything?
>> Looking at notify(), it appears the unqualified my_name will stay
>> on the hosts list, because notify_host() will fail since the
>> smn_lookup() fails and will always set host->ai = NULL. Unless
>> I am missing something, this will cause notify() to increment
>> hp->retries and insert the hp pointer back on the host list.
>> I don't see how that cycle will broken....
> 
> host->my_name isn't used to generate the recipient's address, host->name
> is.
> 
> host->my_name is the _argument_ of an SM_NOTIFY request.  That argument
> is used as a search key by the remote, but sm-notify does not use this
> string for DNS resolution.
Ok.. I see that now... thanks...

steved.
