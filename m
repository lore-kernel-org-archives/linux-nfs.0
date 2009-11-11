From: Patroklos Argyroudis <argp-YZAGAMbGdGKGw+nKnLezzg@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow
 in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Wed, 11 Nov 2009 09:51:28 +0200
Message-ID: <20091111075128.GA28323@evola>
References: <bug-14546-10286@http.bugzilla.kernel.org/>
 <20091110152908.7558a471.akpm@linux-foundation.org>
 <967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Linux Network Developers <netdev@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:40154 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbZKKIRI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 03:17:08 -0500
In-Reply-To: <967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 10, 2009, at 6:29 PM, Andrew Morton wrote:
> >
> >Please don't submit patches via bugzilla.
> >
> >Please prepare this patch as per Documentation/SubmittingPatches and
> >email it to all the recipients of this email, thanks.

Ok, I will do so.

On Tue, Nov 10, 2009 at 06:38:05PM -0500, Chuck Lever wrote:
> Why wouldn't you bump the size of the buffer by two as well?
> Otherwise valid universal addresses that are RPCBIND_MAXUADDRLEN
> bytes long will fail here.
> 
> >	memcpy(buf, uaddr, uaddr_len);

There is no need to increase the size of the buffer since the new check
(if (uaddr_len > sizeof(buf) - 2)) will terminate the function in case
the valid universal address is RPCBIND_MAXUADDRLEN bytes.

Cheers,
Patroklos
