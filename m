From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 15/23] SUNRPC: rpcbind actually interprets r_owner string
Date: Fri, 27 Mar 2009 10:18:59 +1100
Message-ID: <49CC0D63.8090004@sgi.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004713.32404.63163.stgit@ingres.1015granger.net> <49CB439D.5080401@sgi.com> <994CA980-BA59-4F8E-B510-4079A175BFEF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:60066 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754544AbZCZXTb (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 19:19:31 -0400
In-Reply-To: <994CA980-BA59-4F8E-B510-4079A175BFEF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Mar 26, 2009, at 4:58 AM, Greg Banks wrote:
>> Chuck Lever wrote:
>>>
>>> Our port of rpcbind (from Sun) assumes this string contains a numeric
>>> UID value, not alphabetical or symbolic characters, but checks this
>>> value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all other
>>> cases, rpcbind ignores the contents of the r_owner string.
>>
>> Not that this makes the slightest difference to the usefulness of the
>> patch, but it sounds like pretty strange behaviour for an rpcbind server
>> to be using an incoming r_owner value off the wire under any
>> circumstances.
>
> It's ignored for wire requests.  r_owner is used only for AF_LOCAL
> requests (ie a local file socket) where the kernel can guarantee the
> owner.
>
>
Sorry, I'm confused now.  Consider the r_owner field in the rpcb
structure whose XDR representation flows through the AF_LOCAL socket; is
that used by rpcbind at all?  I don't understand how the kernel would
guarantee that?

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

