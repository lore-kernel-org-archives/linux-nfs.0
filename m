Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933009AbaCTOMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Mar 2014 10:12:38 -0400
Message-ID: <532AF753.8060607@RedHat.com>
Date: Thu, 20 Mar 2014 10:12:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>		 <53286A9D.2020007@RedHat.com>		 <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>		 <53288146.4010601@RedHat.com>	 <1395168308.11244.3.camel@leira.trondhjem.org>	 <532897DE.6060204@RedHat.com>	 <EB317FC8-D521-4D80-98D7-FA48B0B9AF0C@primarydata.com>	 <5329900C.3040200@RedHat.com>	 <DAF0940D-107D-4251-B00A-DE829A31B36E@primarydata.com>	 <5329A4B3.20601@RedHat.com>	 <0C0E5EE2-E7BD-4BE3-961F-3B632B45F026@primarydata.com>	 <5329CF7C.7090308@RedHat.com> <1395250160.7168.1.camel@leira.trondhjem.org> <5329E062.9030103@RedHat.com> <34E0F031-281D-4409-8969-B0297EDA0EC4@primarydata.com>
In-Reply-To: <34E0F031-281D-4409-8969-B0297EDA0EC4@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2014 03:41 PM, Trond Myklebust wrote:
> 
> On Mar 19, 2014, at 14:22, Steve Dickson <SteveD@redhat.com> wrote:
>>
>> What's going on is-ECONNREFUSED is being seen in call_connect_status() 
>> and the task is not a soft connection. So call_timeout() is call which 
>> eventual times out the mount… 
> 
> This is what is confusing me. I’d expect that the rpc_ping() would be the 
> first thing to be sent on the wire by rpc_create(), and that ping 
> should normally have the RPC_SOFTCONN flag set.
> 
>> So just for fun I make the SETCLIENTID rpc soft, but for some
>> reason that didn't work either... I thought for sure it would... 
I see you point... Using quick systemtap scripts it turns out
rpc_ping is not failing (returns 0x0) and it should because
the server is definitely down!  

steved.


