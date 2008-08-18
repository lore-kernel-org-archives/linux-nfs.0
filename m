From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
	export.
Date: Mon, 18 Aug 2008 15:20:58 -0400
Message-ID: <1219087258.7192.19.camel@localhost>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Grant Coady <gcoady.lk@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51891 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbYHRTVD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2008 15:21:03 -0400
In-Reply-To: <p6lha4te54h04qdbnos1mcemdmn1cfca6s-e09XROE/p8c@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-18 at 12:02 +1000, Grant Coady wrote:
> Hi there,
> 
> I've been using NFS here for years, lately there's something odd going on 
> since about a month or so.  Previously reported last month:
> http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last
> 
> Now with 2.6.27-rc3 on one of the client boxes I get a complete stall 
> at odd times when accessing the server's exported directory, cannot 
> see a pattern to it.  Eventually recovers after a Ctrl-C.  Nothing in 
> the server or client log files.  Not easy to reproduce either.
> 
> The server runs 2.6.26.2 at the moment.
> 
> Server config, etc: http://bugsplatter.id.au/kernel/boxen/deltree/
> Client config, etc: http://bugsplatter.id.au/kernel/boxen/pooh/

Please try to reproduce the hang, then do

	echo 0 >/proc/sys/sunrpc/rpc_debug

and send the output from 'dmesg'...

Cheers
  Trond

