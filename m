From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting a server.
Date: Sun, 22 Feb 2009 15:01:26 -0500
Message-ID: <56CFFD72-D5AB-4A05-9AF3-C4A420E1DDC3@oracle.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com> <499FB08B.1070200@candelatech.com> <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com> <49A0EFA9.6010602@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:26426 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbZBVUBk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 15:01:40 -0500
In-Reply-To: <49A0EFA9.6010602@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 22, 2009, at Feb 22, 2009, 1:24 AM, Ben Greear wrote:
> Chuck Lever wrote:
>>
>> Would lockd also need to have this information too (passed in via  
>> nlmclnt_inet)?
> I found an fs/lockd directory, but cannot find 'nlmclnt_inet'  
> anywhere in the kernel or nfs-utils.

I misspelled the name.  I meant nlmclnt_init().  But it looks like you  
already found that.

>> Would we also want kernel rpcbind requests to be sensitive to the  
>> passed-in bind address?
>
> It seems from searching net/sunrpc dir that kernel_bind is called  
> appropriately which should
> bind the a local addr if correct information is passed in, at  
> least.   This must be working
> (assuming NFS calls this code eventually) since I *am* getting at  
> least most of the NFS traffic
> correctly bound to the specified bindaddr.

rpcbind is not the same as a socket bind.  It's a database that maps  
an RPC program name/number to a socket port. Look in linux/net/sunrpc/ 
rpcb_clnt.c.  For the mount command, it's in nfs-utils/support/nfs/ 
{getport,rpc_socket}.c.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
