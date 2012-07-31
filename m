Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754175Ab2GaOpu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:45:50 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <501037B6.9080800@netapp.com>
References: <501037B6.9080800@netapp.com> <20120725155336.24392.25186.stgit@warthog.procyon.org.uk> <20120725155347.24392.44505.stgit@warthog.procyon.org.uk>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        steved@redhat.com, jlayton@redhat.com
Subject: Re: [PATCH 2/2] NFS: Combine the idmapper key types
Date: Tue, 31 Jul 2012 15:45:46 +0100
Message-ID: <6767.1343745946@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Schumaker <bjschuma@netapp.com> wrote:

> > +	/* Use the non-legacy route unless given auxiliary data */
> > +	if (!aux)
> > +		return call_sbin_request_key(cons, op, aux);
> 
> struct idmap-s are created when the server is mounted, so I don't think "aux" will ever be null here.

I've posted a new version of the patches with this fixed and with
nfs_idmap_upcall() restructured a bit so as not to do the allocations if we
don't have to.

David
