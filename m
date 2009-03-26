From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 15/23] SUNRPC: rpcbind actually interprets r_owner string
Date: Thu, 26 Mar 2009 19:58:05 +1100
Message-ID: <49CB439D.5080401@sgi.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004713.32404.63163.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:52494 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755790AbZCZI61 (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 04:58:27 -0400
In-Reply-To: <20090319004713.32404.63163.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>
> Our port of rpcbind (from Sun) assumes this string contains a numeric
> UID value, not alphabetical or symbolic characters, but checks this
> value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all other
> cases, rpcbind ignores the contents of the r_owner string.
>   

Not that this makes the slightest difference to the usefulness of the
patch, but it sounds like pretty strange behaviour for an rpcbind server
to be using an incoming r_owner value off the wire under any circumstances.

If I read the Irix and Solaris rpcbind source correctly, they will
(sensibly, IMO) ignore incoming r_owner values in all cases.  When an
owner string is needed (during SET for storing in the internal data
structure, and during UNSET for checking against the internal data
structure) it is calculated from SVCXPRT itself and not from anything
the client sends.  The calculation returns one of:

a) if the transport is over TLI loopback, a numerical representation of
the peer process UID as reported by the special magical TLI kernel hack
which reliably returns that, or

b) if the transport is over IP and the peer port is privileged, the
string "superuser", or

c) otherwise, the string "unknown".

AFAICS the only sensible use for the r_owner field is reporting the
internally-calculated value back to the client, e.g. for the "rpcinfo
-s" display.

> The reference user space implementation of rpcb_set(3) uses a numeric
> UID for all SET/UNSET requests (even via the network) and an empty
> string for all other requests.  We emulate that behavior here to
> maintain bug-for-bug compatibility.
>   

Fair enough.

Reviewed-by: Greg Banks <gnb@sgi.com>

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

