From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 7/9] sunrpc: The per-net skeleton
Date: Mon, 20 Sep 2010 22:54:28 +0400
Message-ID: <4C97ADE4.6030503@parallels.com>
References: <4C90BADB.10700@parallels.com> <4C90BBE9.6000105@parallels.com> <20100920171924.GM4580@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30871 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab0ITSyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 14:54:54 -0400
In-Reply-To: <20100920171924.GM4580@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/20/2010 09:19 PM, J. Bruce Fields wrote:
> On Wed, Sep 15, 2010 at 04:28:25PM +0400, Pavel Emelyanov wrote:
>> @@ -38,18 +58,26 @@ init_sunrpc(void)
>>  	err = rpcauth_init_module();
>>  	if (err)
>>  		goto out3;
>> +
>> +	cache_initialize();
>> +
>> +	err = register_pernet_subsys(&sunrpc_net_ops);
>> +	if (err)
>> +		goto out4;
>>  #ifdef RPC_DEBUG
>>  	rpc_register_sysctl();
>>  #endif
>>  #ifdef CONFIG_PROC_FS
>>  	rpc_proc_init();
>>  #endif
>> -	cache_initialize();
>>  	cache_register(&ip_map_cache);
>>  	cache_register(&unix_gid_cache);
>>  	svc_init_xprt_sock();	/* svc sock transport */
>>  	init_socket_xprt();	/* clnt sock transport */
>>  	return 0;
>> +
>> +out4:
>> +	unregister_pernet_subsys(&sunrpc_net_ops);
> 
> If register_pernet_subsys() failed, then shouldn't this be unnecessary?
> Maybe this should be rpcauth_remove_module()?

Ouch! Of course you're right here... Will fix.

> --b.
