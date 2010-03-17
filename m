From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] sm-notify: Send fully-qualified and unqualified mon_names
Date: Wed, 17 Mar 2010 10:39:12 -0400
Message-ID: <4BA0E990.4080206@oracle.com>
References: <20100315174453.2586.40876.stgit@localhost.localdomain> <20100315175145.2586.1215.stgit@localhost.localdomain> <4BA0B0A4.6020705@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:63796 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0CQOj4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 10:39:56 -0400
In-Reply-To: <4BA0B0A4.6020705-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2010 06:36 AM, Steve Dickson wrote:
> On 03/15/2010 01:51 PM, Chuck Lever wrote:
>> During any file locking interaction between an NFS client and server,
>> the client tells the server what hostname it will use as the mon_name
>> argument of the SM_NOTIFY request sent by the client when it reboots.
>> This is the "caller_name" argument of an NLMPROC_LOCK request.
>>
>> The server, however, never tells the client what mon_name argument
>> it will use when sending an SM_NOTIFY request.  In order to recognize
>> the server, clients usually guess what mon_name the server might
>> send, by using the server hostname provided by the user on the mount
>> command line.
>>
>> Frequently, the user provides an unqualified server name on the mount
>> command.  The server might then call the client back with a fully
>> qualified domain name, which might not match in some cases.
>>
>> Solaris, and perhaps other implementations, attempt to mitigate this
>> problem by sending two SM_NOTIFY requests to each peer: one with an
>> unqualified mon_name argument, and one with a fully qualified mon_name.
>>
>> Implement such a scheme for sm-notify.
>>
>> Since my_name is almost always the fully-qualified hostname associated
>> with the local system, just wiping the left-most '.' in the my_name
>> argument and sending another SM_NOTIFY is nearly always sufficient.
>>
>> Signed-off-by: Chuck Lever<chuck.lever@oracle.com>
>> ---
>>
>>   utils/statd/sm-notify.c |   21 +++++++++++++++++----
>>   1 files changed, 17 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
>> index 2d14668..437e37a 100644
>> --- a/utils/statd/sm-notify.c
>> +++ b/utils/statd/sm-notify.c
>> @@ -634,15 +634,28 @@ recv_rpcbind_reply(struct sockaddr *sap, struct nsm_host *host, XDR *xdr)
>>   }
>>
>>   /*
>> - * Successful NOTIFY call. Server returns void, so nothing
>> - * we need to do here.
>> + * Successful NOTIFY call. Server returns void.
>> + *
>> + * Try sending another SM_NOTIFY with an unqualified "my_name"
>> + * argument.  Reuse the port number.  If "my_name" is already
>> + * unqualified, we're done.
>>    */
>>   static void
>>   recv_notify_reply(struct nsm_host *host)
>>   {
>> -	xlog(D_GENERAL, "Host %s notified successfully", host->name);
>> +	char *dot = strchr(host->my_name, '.');
>>
>> -	smn_forget_host(host);
>> +	if (dot != NULL) {
>> +		*dot = '\0';
>> +		host->send_next = time(NULL);
>> +		host->xid = 0;
>> +		if (host->timeout>= NSM_MAX_TIMEOUT / 4)
>> +			host->timeout = NSM_MAX_TIMEOUT / 4;
>> +		insert_host(host);
> What happens when host->my_name now resolves to host in a
> different domain? Will this mean we now will be sending SM_NOTIFYs
> to random hosts?

> Also, what happens when host->my_name does not resolve to anything?
> Looking at notify(), it appears the unqualified my_name will stay
> on the hosts list, because notify_host() will fail since the
> smn_lookup() fails and will always set host->ai = NULL. Unless
> I am missing something, this will cause notify() to increment
> hp->retries and insert the hp pointer back on the host list.
> I don't see how that cycle will broken....

host->my_name isn't used to generate the recipient's address, host->name is.

host->my_name is the _argument_ of an SM_NOTIFY request.  That argument 
is used as a search key by the remote, but sm-notify does not use this 
string for DNS resolution.

Grep for "my_name" in sm-notify.c to confirm this.

-- 
chuck[dot]lever[at]oracle[dot]com
