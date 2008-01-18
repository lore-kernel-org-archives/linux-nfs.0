From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 12:10:33 -0500
Message-ID: <1200676233.7781.34.camel@heimdal.trondhjem.org>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net>
	 <1200675753.7781.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Fredrik Lindgren <fli-FpffG6+3qsA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:51742 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757942AbYARRKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 12:10:37 -0500
In-Reply-To: <1200675753.7781.32.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-18 at 12:02 -0500, Trond Myklebust wrote:
> It would be interesting to see the 'rpc bklog' parameter in order to
> confirm if the requests are being held up in the backlog queue.
> Unfortunately, there appears to be a bug in iostat-ms: it appears to be
> reading the 'number of requests in flight' where it should be reading
> the 'length of backlog queue' parameter.

BTW: the same bug exists in the 'mountstats' utility. The same patch
fixes the issue there too...

Trond

