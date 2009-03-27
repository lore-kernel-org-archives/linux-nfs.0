From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 15/23] SUNRPC: rpcbind actually interprets r_owner string
Date: Sat, 28 Mar 2009 09:02:07 +1100
Message-ID: <49CD4CDF.8080806@sgi.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004713.32404.63163.stgit@ingres.1015granger.net> <49CB439D.5080401@sgi.com> <994CA980-BA59-4F8E-B510-4079A175BFEF@oracle.com> <49CC0D63.8090004@sgi.com> <CBF484BB-BF9A-4C0D-A56E-D8DFC394A966@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:49669 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752193AbZC0WCd (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2009 18:02:33 -0400
In-Reply-To: <CBF484BB-BF9A-4C0D-A56E-D8DFC394A966@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Mar 26, 2009, at 7:18 PM, Greg Banks wrote:
>
> rpcbind then throws this away and uses getsockopt(SO_PEERCRED).  On
> network sockets I think that's always going to return a uid of -1, but
> for AF_LOCAL it will have a meaningful value.
Aha.  Unconfused now,  thanks.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

