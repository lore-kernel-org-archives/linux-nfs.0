From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
	support is built in
Date: Fri, 30 Jan 2009 16:55:52 -0500
Message-ID: <20090130215552.GI31166@fieldses.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org> <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com> <1233350290.9741.42.camel@heimdal.trondhjem.org> <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53111 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923AbZA3Vzy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 16:55:54 -0500
In-Reply-To: <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 04:30:10PM -0500, Chuck Lever wrote:
> On Jan 30, 2009, at Jan 30, 2009, 4:18 PM, Trond Myklebust wrote:
>> If so, it sounds to me as if
>> we _must_ have lockd and the callback server set up IPv6 sockets
>> whenever they are available.
>
> That's what the code does now.  The problem is exactly what does  
> "whenever they are available" mean?
>
> Are you suggesting we shouldn't ever fall back to AF_INET?  (I'm OK with 
> that answer, but would like a discussion).  This means that if I try an 
> IPv4 mount on a system built with an IPv6 module, but the module is 
> unloadable, all mounts (even IPv4) fail outright.  Apparently a lot of 
> folks blacklist their IPv6 modules.

It sounds reasonable to me for now to take "whenever they are available"
to mean "whenever ipv6 can be loaded", and to fall back on ipv4 only in
that case.  I guess the sort of case that would handle badly would be:

	do an ipv4 mount
		- try to find ipv6, fail, start lockd up ipv4-only
	do an ipv6 mount
		- no ipv6 support, so mount fails.
	insmod ipv6
	retry the ipv6 mount
		- oops, too late to make lockd listen on ipv6.  Fail
		  this too.

But it'd still be an improvement.

For the future:

> AF_INET6 listeners can receive AF_INET packets too, but don't have to.  
> My motivation was to use a single listener so we don't have to support 
> multiple family listeners for each transport protocol in the server-side 
> code.

How hard would that be exactly?

> Also, having a separate IPv6-only listener means that someone can 
> come along and hijack the IPv4 packets on that port.

Starting listeners on both as early as possible reduces but doesn't
eliminate the chance of that happening.  Don't we just have to assume
users of low port numbers are well-behaved to some degree?

--b.
