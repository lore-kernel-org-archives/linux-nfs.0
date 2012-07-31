Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36402 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755654Ab2GaQhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 12:37:11 -0400
Date: Tue, 31 Jul 2012 12:37:08 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NFS: Fix a number of bugs in the idmapper
Message-ID: <20120731163708.GE27834@fieldses.org>
References: <1343746117.5528.3.camel@lade.trondhjem.org>
 <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
 <6978.1343746575@warthog.procyon.org.uk>
 <1343747261.5528.10.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1343747261.5528.10.camel@lade.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 03:07:42PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-07-31 at 15:56 +0100, David Howells wrote:
> > Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
> > 
> > > This patch should already be present in nfs-for-next as of yesterday.
> > > (I've been on a 2 week vacation).
> > 
> > How about the second patch?  I posted an updated version of it just now.
> > 
> > Note that the second patch or something like it is likely to be necessary to
> > reduce the load on the keyring (you end up having duplicate keys of different
> > key types that can't be shared).
> 
> We don't expect people to be running both types of idmapper at the same
> time. Normally, the distribution will set up one or the other. However
> if both idmappers do happen to be configured, then we want to always
> choose the non-legacy type...

On a quick check....  It looks like F17 has /usr/sbin/nfsidmap, and also
runs rpc.idmapd for the server.  While rpc.idmap does have a "-S"
option, it's not using that.

But that should be easy to fix--I'll go look....

--b.
