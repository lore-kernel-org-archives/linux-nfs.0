Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4747 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756895Ab0ITQeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 12:34:15 -0400
Message-ID: <4C978CE6.5080508@parallels.com>
Date: Mon, 20 Sep 2010 20:33:42 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
References: <4C90BADB.10700@parallels.com> <20100920161326.GL4580@fieldses.org>
In-Reply-To: <20100920161326.GL4580@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> Looking forward to your feedback.
> 
> What are you thinking of as a use-case for this?

To make it possible run both NFS server and client in containers.
I know, that the NFS client is already a filesystem, but such
things as its internal servers and clients abstraction require
isolation from each other in containers terms.

> I think it would be useful to able to run what appear to be multiple NFS
> servers on a single host; 

Yup, this is one of the goals.

> and for that, we would want to vary more than
> just the ip_map_cache.  The export-related caches (nfsd.fh and
> nfsd.export), at least.

Sure! The thing is that the full containerization of that stuff is
too many patches and I'm not sure that you and other maintainers wish
to review the 100-patch set in one go ;)

I want to find out what git tree to hack on and prepare small patch
sets making things step-by-step. This one is just the first in a row.

> --b.
> 

Thanks,
Pavel
