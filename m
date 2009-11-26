From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Thu, 26 Nov 2009 10:01:47 -0500
Message-ID: <1259247707.6715.46.camel@localhost>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
	 <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
	 <1259159512.3314.12.camel@localhost>
	 <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44586 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760270AbZKZPBt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Nov 2009 10:01:49 -0500
In-Reply-To: <64b4daae0911251511q7a070b0aj1c07cdc5d6719b41-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-11-26 at 00:11 +0100, Stephen R. van den Berg wrote: 
> 1.2.3.167 is the Linux client kernel which locks up, 1.2.3.151 is the
> unfs server.
> It looks like the client terminates the TCP connection.  The server
> confirms it, the client then sends a final acknowledge.  At that point
> the client kernel locks up in the infinite loop.

OK. Have you tried running with RPCDBG_TRANS debugging enabled? I
suspect you might see a flood of 'sendmsg returned unrecognized error'
or 'connect returned unhandled error' messages if you do.

Trond

