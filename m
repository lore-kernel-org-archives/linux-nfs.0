From: Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS export.
Date: Wed, 20 Aug 2008 11:10:14 +1000
Message-ID: <75rma4544lqk5otlk58jjcn4kf5kb27fm7@4ax.com>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com> <1219087258.7192.19.camel@localhost>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Coady <gcoady.lk@gmail.com>, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.mail-hub.dodo.com.au ([123.2.6.238]:47505 "EHLO
	relay03.mail-hub.dodo.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754795AbYHTBKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 21:10:42 -0400
In-Reply-To: <1219087258.7192.19.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Mon, 18 Aug 2008 15:20:58 -0400, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

>On Mon, 2008-08-18 at 12:02 +1000, Grant Coady wrote:
>> Hi there,
>> 
>> I've been using NFS here for years, lately there's something odd going on 
>> since about a month or so.  Previously reported last month:
>> http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last
>> 
>> Now with 2.6.27-rc3 on one of the client boxes I get a complete stall 
>> at odd times when accessing the server's exported directory, cannot 
>> see a pattern to it.  Eventually recovers after a Ctrl-C.  Nothing in 
>> the server or client log files.  Not easy to reproduce either.
>> 
>> The server runs 2.6.26.2 at the moment.
>> 
>> Server config, etc: http://bugsplatter.id.au/kernel/boxen/deltree/
>> Client config, etc: http://bugsplatter.id.au/kernel/boxen/pooh/
>
>Please try to reproduce the hang, then do
>
>	echo 0 >/proc/sys/sunrpc/rpc_debug
>
>and send the output from 'dmesg'...

dmesg and logs from client machine showed nothing, dmesg from server:

-pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait -action- ---ops--

(nothing, nada, zilch after what looks like the header line)

Situation, first use of 'df' after reboot, client machine hung for many 
seconds before the /home/common export showed up, this is not repeatable. 
Mounting another export and doing 'df' again had no delays.

Client is running 2.6.27-rc3-git5 (x86_64) at the moment, configs, etc 
at: http://bugsplatter.id.au/kernel/boxen/pooh64/

Server as above.  Am I supposed to have some debugging turned on in the 
.configs?

Grant.  
