Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753497Ab2GaPF3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 11:05:29 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1343746464.5528.7.camel@lade.trondhjem.org>
References: <1343746464.5528.7.camel@lade.trondhjem.org> <20120731144234.6664.85664.stgit@warthog.procyon.org.uk> <20120731144245.6664.49160.stgit@warthog.procyon.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com, "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NFS: Combine the idmapper key types
Date: Tue, 31 Jul 2012 16:05:23 +0100
Message-ID: <7142.1343747123@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> > The NFS idmapper has two key types (normal and legacy) but should only use
> > one if it can - otherwise it risks having twice as many keys as it would
> > otherwise need.
> 
> Why is this? Do we add keys in the case where the 'normal' upcall fails?

Yes.  The idmapper code defines a second key type and uses the key_type
struct's .request_key() op to do its own thing (ie. upcall to a running
rpc.idmapd process).  The idmapper code, however, calls request_key*() to make
use of this, and that will create a new key.

If only the legacy idmapper is available, you will end up with two keys added
to the keyring for each operation, one of the 'normal' type and one of the
'legacy' type.

The 'normal' key will be negative, it is true, but it still takes up a slot
until the garbage collector eats it, and can displace an otherwise good key.

Negative keys are added to the keyring for a time set by their timeout to
limit the rate of key lookups.

David
