Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469Ab2DQXAT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 19:00:19 -0400
Subject: Re: [PATCH 4/5] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20120417222825.GA32619@fieldses.org>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
	 <1334669948-4156-5-git-send-email-simo@redhat.com>
	 <20120417222825.GA32619@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Apr 2012 19:00:16 -0400
Message-ID: <1334703616.16658.220.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-04-17 at 18:28 -0400, J. Bruce Fields wrote:
> On Tue, Apr 17, 2012 at 09:39:07AM -0400, Simo Sorce wrote:
> > This patch implements a sunrpc client to use the services of the gssproxy
> > userspace daemon.
> > 
> > In particular it allows to perform calls in user space using an RPC
> > call instead of custom hand-coded upcall/downcall messages.
> 
> The "hand-coded" messages aren't really particularly hard to generate or
> parse.  Let's just drop that argument.

Sorry wasn't meant as an argument, just a fact.
I guess hand-coded is the wrong term, after all all the RPC code in the
kernel is hand-coded as well :-)
(userspace uses rpcgen)

I will drop the line in future if it feels contentious.

> > Currently only accept_sec_context is implemented as that is all is needed for
> > the server case.
> > 
> > File server modules like NFS and CIFS can use full gssapi services this way,
> > once init_sec_context is also implemented.
> 
> What's the situation with CIFS, by the way?  (How does it currently do
> gssapi, and what are their plans?)

At the moment I think the cifs.ko code uses an upcall mechanism based on
storing blobs in the kernel keyring to have it call a userspace helper.
Last time I spoke with Jeff Layton he expressed interest in a unified
mechanism like gss-proxy to reduce duplication in the system.
I haven't discussed it further.

> > For the NFS server case this code allow to lift the limit of max 2k krb5
> > tickets. This limit is prevents legitimate kerberos deployments from using krb5
> > authentication with the Linux NFS server as they have normally ticket that are
> > many kilobytes large.
> > 
> > It will also allow to lift the limitation on the size of the credential set
> > (uid,gid,gids) passed down from user space for users that have very many groups
> > associated. Currently the downcall mechanism used by rpc.svcgssd is limited
> > to around 2k secondary groups of the 65k allowed by kernel structures.
> 
> Remind me what remains to be done before that works?

The sunrpc code that deals with AF_LOCAL needs to be fixed to use a
stream (tcp like) reader function instead of using the datagram (udp)
code, after all it *is* declared as a 'stream' facility, not a datagram
one.
It shouldn't really be a lot of work as it should do basically the same
thing the tcp code does. I am no expert there but I wonder if the
available tcp-named functions couldn't just be reused as is with perhaps
some minor tweaks to distinguish between AF_INET and AF_LOCAL if
necessary anywhere in that path.
Haven't yet looked deeply enough to be able to tell, I am quite new to
this code and would not mind an experienced hand to give some advice.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

