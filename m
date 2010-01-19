From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Tue, 19 Jan 2010 16:06:41 -0500
Message-ID: <96E6F818-9604-4B3E-B7B5-19C4248CA4D9@oracle.com>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com> <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com> <20100119153826.67dd97a5@tlielax.poochiereds.net> <1263934304.4920.4.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	steved@redhat.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50117 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598Ab0ASVHL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jan 2010 16:07:11 -0500
In-Reply-To: <1263934304.4920.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 19, 2010, at 3:51 PM, Trond Myklebust wrote:

> On Tue, 2010-01-19 at 15:38 -0500, Jeff Layton wrote:
>> On Tue, 19 Jan 2010 10:43:34 -0500
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>> I think that doesn't describe this workaround adequately.  This is a
>>> temporary crutch that prevents us from using IPv6 if "proto=" isn't
>>> specified.  The underlying problem here is that nfs_lookup() returns
>>> just one address.
>>>
>>
>> Yes. The best solution would be to somehow try all addresses in the
>> list until one works. That's a larger project however and we'll
>> probably need some significant kernel changes to handle that anyway.
>
> Why would that involve kernel changes? I'm assuming that we can just
> retry the mount call if we see that the server isn't listening on a
> particular ip address+port combination.

For NFSv2/v3, the mount command can poke at the server's rpcbind  
service to discover that the server won't support IPv6.  For NFSv4,  
the kernel jumps straight for a TCP connection, without consulting  
rpcbind

I think Jeff is using a pre-2.6.33 kernel, which basically hangs when  
the server refuses to connect in this case.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




