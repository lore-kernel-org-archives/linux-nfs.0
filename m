Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbcGTL3d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2016 07:29:33 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2EB4A461D6
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jul 2016 11:29:33 +0000 (UTC)
Received: from [10.10.61.143] (vpn-61-143.rdu2.redhat.com [10.10.61.143])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u6KBTVnQ008257
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jul 2016 07:29:32 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Re: nfsd delays between svc_recv and gss_check_seq_num
Date: Wed, 20 Jul 2016 07:31:06 -0400
Message-ID: <B84702FE-2019-4FDB-A358-F956F082EB98@redhat.com>
In-Reply-To: <alpine.OSX.2.19.9992.1607200628390.6057@planck.local>
References: <alpine.OSX.2.19.9992.1604100724080.44797@planck>
 <alpine.OSX.2.19.9992.1607200628390.6057@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uh, something is clearly wrong with my mailer now..

On 20 Jul 2016, at 6:33, Red Hat wrote:

> On Sun, 10 Apr 2016, Benjamin Coddington wrote:
>
>> My client hangs on xfstests generic/074 on a krb5 mount, and I've 
>> found that
>> the linux server is silently discarding one or more RPCs because the 
>> GSS
>> sequence numbers are outside the sequence window.
>>
>> The reason is that sometimes one of the nfsd threads takes a long 
>> time
>> between receiving the RPC and then checking if the sequence is within 
>> the
>> window.  That delay allows the other nfsd threads to quickly move the 
>> window
>> forward out of range.
>>
>> If the server discards the RPC then that causes then the client to 
>> wait
>> forever for a response or until the connection is reset.
>>
>> By inserting tracepoints, I think I found two sources of delay:
>>
>>  1) gss_svc_searchbyctx() uses dup_to_netobj() which has a kmemdup 
>> with
>> GFP_KERNEL.  It does this because presumabely it doesn't know how big 
>> the
>> context handle should be.
>>
>>  2) gss_verify_mic() uses make_checksum() which eventually gets to
>> crypto_alloc_hash() with GFP_KERNEL.
>>
>> For the first delay, can we assume the context handles are all going 
>> to be
>> the same size?  It looks like the handle is assigned by the server, 
>> so it
>> seems like we should be able to know beforehand how large they are.
>>
>> For the second allocation -- I haven't thrown a lot of thought into 
>> what
>> could be done to fix it.. seems a bit tricker.  I'll think about both 
>> of
>> these a bit more, but I thought in the meantime to ask if anyone has
>> thoughts about this problem.  Maybe we can to the sequence check 
>> before
>> verify_mic -- but then a message that fails verification could flip 
>> the
>> sequence bit..
>
> I haven't gotten back to this problem yet, but in the interest of not
> forgetting about it I want to self-reply that some testing with 
> kmemleak
> showed a bunch of these on trond's linux-next branch.  I haven't done 
> any
> other investigation:
>
> unreferenced object 0xffff8800545bfe48 (size 16):
>   comm "nfsd", pid 1548, jiffies 4294980011 (age 54.660s)
>   hex dump (first 16 bytes):
>     2a 86 48 86 f7 12 01 02 02 6b 6b 6b 6b 6b 6b a5  *.H......kkkkkk.
>   backtrace:
>     [<ffffffff817c1f2e>] kmemleak_alloc+0x4e/0xb0
>     [<ffffffff81220767>] __kmalloc_track_caller+0x187/0x2a0
>     [<ffffffff811d6cb0>] kmemdup+0x20/0x50
>     [<ffffffffc011d86f>] gssx_dec_buffer+0x8f/0xa0 [auth_rpcgss]
>     [<ffffffffc011e252>] gssx_dec_accept_sec_context+0x242/0x58e
> [auth_rpcgss]
>     [<ffffffffc0147e57>] rpcauth_unwrap_resp+0xa7/0xe0 [sunrpc]
>     [<ffffffffc01386e3>] call_decode+0x1e3/0x810 [sunrpc]
>     [<ffffffffc01441b1>] __rpc_execute+0x91/0x460 [sunrpc]
>     [<ffffffffc01468a1>] rpc_execute+0x61/0xc0 [sunrpc]
>     [<ffffffffc013a351>] rpc_run_task+0xf1/0x130 [sunrpc]
>     [<ffffffffc013a3e0>] rpc_call_sync+0x50/0xc0 [sunrpc]
>     [<ffffffffc011d3fa>] gssp_accept_sec_context_upcall+0x1aa/0x4b0
> [auth_rpcgss]
>     [<ffffffffc011b9c5>] svcauth_gss_proxy_init+0x175/0x520 
> [auth_rpcgss]
>     [<ffffffffc011c172>] svcauth_gss_accept+0x402/0xb60 [auth_rpcgss]
>     [<ffffffffc014d77d>] svc_authenticate+0xed/0xf0 [sunrpc]
>     [<ffffffffc01491e4>] svc_process_common+0x244/0x690 [sunrpc]
>
> Ben
