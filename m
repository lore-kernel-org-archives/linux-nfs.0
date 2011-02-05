Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753Ab1BEM7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Feb 2011 07:59:54 -0500
Date: Sat, 5 Feb 2011 08:03:32 -0500
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Unified keys for NFS, CIFS and AFS for security
 data
Message-ID: <20110205080332.4899b352@corrin.poochiereds.net>
In-Reply-To: <3599.1295624067@redhat.com>
References: <3599.1295624067@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 21 Jan 2011 15:34:27 +0000
David Howells <dhowells@redhat.com> wrote:

> 
> I'd like to propose a discussion topic for the LSF: how best to implement a
> common key type for use by NFS, CIFS and AFS such that, say, a kerberos key
> can be encapsulated within one and then be pulled out by various filesystems.
> 
> Furthermore, it would be necessary to allow the request_key() upcall mechanism
> to perform GSSAPI queries.
> 

I would be interested in discussing this as well. Currently CIFS
"punts" to some degree and offloads almost all of the SPNEGO blob
construction to userspace. So, for CIFS this would involve moving more
of this code into the kernel. I think that's a good thing since it will
make it easier to do mutual-authentication, etc...

This would make it more plausible to store krb5 credcaches in the
kernel keyring too. Modern MIT krb5 libs can do this today (I think),
but most of the kernel upcalls rely on FILE: credcaches. Breaking that
dependency would be nice.

The difficulty here is that request_key() is "stateless", so we need to
think about how to manage GSSAPI contexts across multiple upcalls...or
plan to implement large swaths of the GSSAPI in-kernel.

It might also be helpful to couple this with some consolidation and
cleanup of the ASN.1 parsing code in the kernel. There are at least 3
separate implementations in the kernel today (one in cifs, one in
sunrpc, and one in iptables).

Since Trond's original email asked what I expertise I would bring to
the table:

I currently maintain the cifs-utils package which contains the
cifs.upcall program, and wrote most of the in-kernel pieces of the
current SPNEGO/krb5 upcall for CIFS. I've also done a some work on
the GSSAPI upcall pieces in the RPC layer and in nfs-utils.

-- 
Jeff Layton <jlayton@redhat.com>
