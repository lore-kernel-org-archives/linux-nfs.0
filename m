From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
 referrals and migration
Date: Fri, 21 Aug 2009 09:42:48 -0400
Message-ID: <20090821094248.23bc54f1@tlielax.poochiereds.net>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	<1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191AbZHUNnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 09:43:19 -0400
In-Reply-To: <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Aug 2009 19:38:53 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> The NFSv4 and NFSv4.1 protocols both allow for the redirection of a client
> from one server to another in order to support filesystem migration and
> replication. For full protocol support, we need to add the ability to
> convert a DNS host name into an IP address that we can feed to the RPC
> client.
> 
> We'll reuse the sunrpc cache, now that it has been converted to work with
> rpc_pipefs.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


I'm happy to see this problem get resolved. Much of this functionality
however is already provided by the keys API. While it's more geared
toward dealing with auth tokens, it's still a fairly decent generic upcall
implementation and could easily have been used here with a lot less new
code added. Why did you decide to roll your own implementation instead?

-- 
Jeff Layton <jlayton@redhat.com>
