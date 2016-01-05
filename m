Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35143 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbcAEAtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 19:49:20 -0500
Received: by mail-pf0-f177.google.com with SMTP id 78so212518811pfw.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 16:49:20 -0800 (PST)
Subject: Re: [PATCH] nfsd: Fix nfsd leaks sunrpc module references
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <20150911104517.GA4947@stefanha-thinkpad.home>
 <5689E3C9.1010708@gmail.com> <20160104223930.GE30315@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>,
        skinsbursky@parallels.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <568B1302.2080803@gmail.com>
Date: Tue, 5 Jan 2016 08:49:06 +0800
MIME-Version: 1.0
In-Reply-To: <20160104223930.GE30315@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/5/2016 06:39, J. Bruce Fields wrote:
> On Mon, Jan 04, 2016 at 11:15:21AM +0800, Kinglong Mee wrote:
>> Stefan Hajnoczi reports,
>> nfsd leaks 3 references to the sunrpc module here:
>>
>>   # echo -n "asdf 1234" >/proc/fs/nfsd/portlist
>>   bash: echo: write error: Protocol not supported
>>
>> Now stop nfsd and try unloading the kernel modules:
>>
>>   # systemctl stop nfs-server
>>   # systemctl stop nfs
>>   # systemctl stop proc-fs-nfsd.mount
>>   # systemctl stop var-lib-nfs-rpc_pipefs.mount
>>   # rmmod nfsd
>>   # rmmod nfs_acl
>>   # rmmod lockd
>>   # rmmod auth_rpcgss
>>   # rmmod sunrpc
>>   rmmod: ERROR: Module sunrpc is in use
>>   # lsmod | grep rpc
>>   sunrpc                315392  3
>>
>> It is caused by nfsd don't cleanup rpcb program for nfsd
>> when destroying svc service after creating xprt fail.
>>
>> Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfssvc.c | 7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>> index ad4e237..543de5f 100644
>> --- a/fs/nfsd/nfssvc.c
>> +++ b/fs/nfsd/nfssvc.c
>> @@ -314,14 +314,13 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
>>  	 * write_ports can create the server without actually starting
>>  	 * any threads--if we get shut down before any threads are
>>  	 * started, then nfsd_last_thread will be run before any of this
>> -	 * other initialization has been done.
>> +	 * other initialization has been done except the rpcb information.
>>  	 */
>> +	svc_rpcb_cleanup(serv, net);
> 
> Are you sure this is right?
> 
> For example, nfsd_create_serv calls svc_destroy on svc_bind failure, is
> it OK to call svc_rpcb_cleanup in that case?

The svc_rpcb_cleanup in nfsd_last_thread is called in svc_shutdown_net,
svc_destroy never call it.

svc_shutdown_net is called in nfsd_destroy only nfsd_serv->sv_nrthreads == 1.

So that, it's ok calling svc_rpcb_cleanup in nfsd_last_thread always.

Is there anything I missing?

thanks,
Kinglong Mee

> 
> --b.
> 
>>  	if (!nn->nfsd_net_up)
>>  		return;
>> -	nfsd_shutdown_net(net);
>> -
>> -	svc_rpcb_cleanup(serv, net);
>>  
>> +	nfsd_shutdown_net(net);
>>  	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
>>  			    "cache\n");
>>  	nfsd_export_flush(net);
>> -- 
>> 2.5.0
> 
