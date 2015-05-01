Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:33112 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbbEANjx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 09:39:53 -0400
Received: by qcrf4 with SMTP id f4so43766997qcr.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 May 2015 06:39:53 -0700 (PDT)
Date: Fri, 1 May 2015 09:39:49 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Jamie Bainbridge <jbainbri@redhat.com>
Cc: linux-nfs@vger.kernel.org, harshula@redhat.com
Subject: Re: Desired RPC client behaviour on socket errors?
Message-ID: <20150501093949.48f9e779@tlielax.poochiereds.net>
In-Reply-To: <284822107.10169266.1430457755109.JavaMail.zimbra@redhat.com>
References: <107624115.10168203.1430457528206.JavaMail.zimbra@redhat.com>
	<284822107.10169266.1430457755109.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 May 2015 01:22:35 -0400 (EDT)
Jamie Bainbridge <jbainbri@redhat.com> wrote:

> Commit 3ed5e2a introduced a change to the RPC client's handling of socket return on connect.
> 
> Prior to this commit, any error return was considered instantly fatal and rpc_exit(task,-EIO) was called.
> 
> After this commit, socket returns ECONNREFUSED ECONNRESET ECONNABORTED ENETUNREACH EHOSTUNREACH are passed back to the caller. This is a good idea and works well.
> 
> However, this commit also causes those returns to call rpc_delay(task,3*HZ) and the RPC connect to retry until the RPC times out. The timeout can be modified with soft/timeo/retrans but defaults to 3 minutes.
> 
> In practice this means if a client tries to mount and there is a permanent network error outside the client, a TCP Reset or an ICMP error might get returned, bu the mount will hang and the client will keep trying to connect many times until the RPC times out. Previously a mount would fail almost straight away.
> 
> It seems 3ed5e2a solves a problem for transient network errors but creates a problem for permanent network errors.
> 
> I agree it's probably desirable for a client application (RPC in this instance) to keep trying to connect until a timeout, and it's good the timeout is configurable, but it's bad that the timeout must be tied to all RPC operations. Someone wanting a quick mount timeout must also suffer a quick NFS operation timeout, not to mention the data corruption risk that goes along with soft.
> 
> Should the RPC client call rpc_exit() on an xprt connect which returns ECONNREFUSED ECONNRESET ECONNABORTED ENETUNREACH EHOSTUNREACH because those returns imply a "more permanent" network issue?
> 
> Disclosure: We came across this because a customer is (ab)using NFSv4 Migrations in a strange way. One server in fs_locations is firewalled behind a TCP Reset and one is not. Depending on which security zone a client is in, it can connect to one server but not the other. This enables clients in both security zones to use the same NFS mount configuration.
> 
> Cheers,
> Jamie
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


I'd say no...

One thing to consider is that it's quite common for servers (Linux or
otherwise) to return those sorts of errors as they are coming up after
a reboot. Network interfaces are often brought online before the nfs
server is ready to accept connections.

If we were to change that then you'd likely see RPCs failing in those
situations, which is almost certainly not what you want.

AFAICT, mount requests should end up trying to do a rpc_ping first,
which should have RPC_TASK_SOFTCONN set. Is that not working for some
reason?

-- 
Jeff Layton <jeff.layton@primarydata.com>
