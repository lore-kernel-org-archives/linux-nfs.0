Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124Ab3A1U0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2013 15:26:49 -0500
Date: Mon, 28 Jan 2013 15:26:43 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
Message-ID: <20130128152643.2b136d37@tlielax.poochiereds.net>
In-Reply-To: <321A7110-AD03-49EB-A158-246FC8BD24E1@oracle.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
	<1359402082-29195-2-git-send-email-jlayton@redhat.com>
	<5AD4F061-69A6-47F5-B20A-34B8DCC2EB5E@oracle.com>
	<20130128150502.4c5f497b@tlielax.poochiereds.net>
	<321A7110-AD03-49EB-A158-246FC8BD24E1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2013 12:16:17 -0800 (PST)
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 28, 2013, at 3:05 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Mon, 28 Jan 2013 11:51:13 -0800 (PST)
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Jan 28, 2013, at 2:41 PM, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> Currently, it only stores the first 16 bytes of any address. struct
> >>> sockaddr_in6 is 28 bytes however, so we're currently ignoring the last
> >>> 12 bytes of the address.
> >>> 
> >>> Expand the c_addr field to a sockaddr_in6,
> >> 
> >> What do you do about link-local addresses?
> >> 
> > 
> > I use rpc_cmp_addr() which should handle the scope correctly for
> > link-local addrs.  Now that you mention it though, I think we may have a
> > bug in __rpc_copy_addr6. It doesn't touch the scope_id at all --
> > shouldn't we be setting the scopeid in that function as well?
> 
> It looks like rpc_copy_addr() is invoked to copy only source addresses, so the scope ID probably doesn't apply.  The comment over rpc_copy_addr() says it explicitly ignores port and scope ID.
> 

Well, it copies the source address of the client, but all of the
callers are in nfsd code. So I think it probably does matter:

Consider a server that has 2 interfaces, and 2 clients with identical
link-local addresses hitting the link local address of each interface.
The only way to distinguish them at that point is to look at their
scope_ids.

In the event that we're not using link-local addresses, the scopeid
should just be ignored. So I think we probably need something like this
patch too:

----------------------[snip]---------------------

sunrpc: copy scope ID in __rpc_copy_addr6

When copying an address, we should also copy the scopeid in the event
that this is a link-local address and the scope matters.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 34206b8..4824286 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -242,6 +242,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
 
 	dsin6->sin6_family = ssin6->sin6_family;
 	dsin6->sin6_addr = ssin6->sin6_addr;
+	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
 	return true;
 }
 #else	/* !(IS_ENABLED(CONFIG_IPV6) */
-- 
1.7.11.7


-- 
Jeff Layton <jlayton@redhat.com>
