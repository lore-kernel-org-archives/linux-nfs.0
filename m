Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:40752 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbEAFWf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 01:22:35 -0400
Date: Fri, 1 May 2015 01:22:35 -0400 (EDT)
From: Jamie Bainbridge <jbainbri@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: harshula@redhat.com
Message-ID: <284822107.10169266.1430457755109.JavaMail.zimbra@redhat.com>
In-Reply-To: <107624115.10168203.1430457528206.JavaMail.zimbra@redhat.com>
Subject: Desired RPC client behaviour on socket errors?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 3ed5e2a introduced a change to the RPC client's handling of socket return on connect.

Prior to this commit, any error return was considered instantly fatal and rpc_exit(task,-EIO) was called.

After this commit, socket returns ECONNREFUSED ECONNRESET ECONNABORTED ENETUNREACH EHOSTUNREACH are passed back to the caller. This is a good idea and works well.

However, this commit also causes those returns to call rpc_delay(task,3*HZ) and the RPC connect to retry until the RPC times out. The timeout can be modified with soft/timeo/retrans but defaults to 3 minutes.

In practice this means if a client tries to mount and there is a permanent network error outside the client, a TCP Reset or an ICMP error might get returned, bu the mount will hang and the client will keep trying to connect many times until the RPC times out. Previously a mount would fail almost straight away.

It seems 3ed5e2a solves a problem for transient network errors but creates a problem for permanent network errors.

I agree it's probably desirable for a client application (RPC in this instance) to keep trying to connect until a timeout, and it's good the timeout is configurable, but it's bad that the timeout must be tied to all RPC operations. Someone wanting a quick mount timeout must also suffer a quick NFS operation timeout, not to mention the data corruption risk that goes along with soft.

Should the RPC client call rpc_exit() on an xprt connect which returns ECONNREFUSED ECONNRESET ECONNABORTED ENETUNREACH EHOSTUNREACH because those returns imply a "more permanent" network issue?

Disclosure: We came across this because a customer is (ab)using NFSv4 Migrations in a strange way. One server in fs_locations is firewalled behind a TCP Reset and one is not. Depending on which security zone a client is in, it can connect to one server but not the other. This enables clients in both security zones to use the same NFS mount configuration.

Cheers,
Jamie
