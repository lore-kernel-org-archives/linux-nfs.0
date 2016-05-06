Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39470 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbcEFCoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2016 22:44:04 -0400
Date: Thu, 5 May 2016 22:44:01 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Configuring NFSv4.0 Kerberos on a multi-homed Linux NFS server
Message-ID: <20160506024401.GC5365@fieldses.org>
References: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com>
 <8198666A-8963-42D2-9C4C-08374F0E8E5D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8198666A-8963-42D2-9C4C-08374F0E8E5D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 05, 2016 at 05:01:58PM -0400, Chuck Lever wrote:
> After some IRC discussion with Bruce, we think the answer
> is "this is not supported in the current Linux NFS server."
> 
> The server does not have a way to determine which service
> principal to use for NFSv4.0 callback operations. It picks
> (probably) the first nfs/ service principal in the server's
> keytab for all callback operations.
> 
> Thus if a Linux NFS server has a keytab, clients can mount
> it with NFSv4.0 (and any security flavor) only on the i/f
> whose hostname matches the name of the nfs/ service
> principal in that server's keytab.

One correction: the mount should still work correctly.  The server just
won't grant any delegations to the client.

> In other words, if the server has a keytab with the
> principals:
> 
>   nfs/server-a
>   nfs/server-b
>   nfs/server-c
> 
> NFSv4.0 will operate correctly only when mounting the
> server via server-a: .
> 
> Clients that do not have a keytab should be able to mount
> with NFSv4.0 via the other interfaces. This is because
> they will not try to negotiate krb5i for lease management,
> and the server will not attempt to use krb5i for callback
> operations.
> 
> Bruce feels this is a corner case, would be difficult to
> address, and is adequately worked around by using NFSv3
> or NFSv4.1 or higher. So currently this is a WONTFIX.

Right, so if there's somebody really need delegations in the multi-homed
NFSv4.0/krb5 case, they're welcomed to look into it--I can't say I'd
turn down good patches (maybe it's not even that hard--may depend on
whether the gss-proxy protocol does what we need?).  But it doesn't seem
like a priority.

--b.

> 
> Copied Bruce to correct anything I might have summarized
> incorrectly.
> 
> --
> Chuck Lever
> 
> 
