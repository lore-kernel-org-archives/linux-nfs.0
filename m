Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33810 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab2DQW20 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 18:28:26 -0400
Date: Tue, 17 Apr 2012 18:28:25 -0400
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120417222825.GA32619@fieldses.org>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
 <1334669948-4156-5-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334669948-4156-5-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2012 at 09:39:07AM -0400, Simo Sorce wrote:
> This patch implements a sunrpc client to use the services of the gssproxy
> userspace daemon.
> 
> In particular it allows to perform calls in user space using an RPC
> call instead of custom hand-coded upcall/downcall messages.

The "hand-coded" messages aren't really particularly hard to generate or
parse.  Let's just drop that argument.

> Currently only accept_sec_context is implemented as that is all is needed for
> the server case.
> 
> File server modules like NFS and CIFS can use full gssapi services this way,
> once init_sec_context is also implemented.

What's the situation with CIFS, by the way?  (How does it currently do
gssapi, and what are their plans?)

> For the NFS server case this code allow to lift the limit of max 2k krb5
> tickets. This limit is prevents legitimate kerberos deployments from using krb5
> authentication with the Linux NFS server as they have normally ticket that are
> many kilobytes large.
> 
> It will also allow to lift the limitation on the size of the credential set
> (uid,gid,gids) passed down from user space for users that have very many groups
> associated. Currently the downcall mechanism used by rpc.svcgssd is limited
> to around 2k secondary groups of the 65k allowed by kernel structures.

Remind me what remains to be done before that works?

--b.
