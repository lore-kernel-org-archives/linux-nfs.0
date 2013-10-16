Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49992 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934098Ab3JPMdU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 08:33:20 -0400
Date: Wed, 16 Oct 2013 05:33:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_file usage
Message-ID: <20131016123315.GA29454@infradead.org>
References: <20131015211445.GA23636@infradead.org>
 <525E2C5C.4020104@primarydata.com>
 <20131016064649.GB28758@infradead.org>
 <525E5228.80200@primarydata.com>
 <20131016085117.GA21665@infradead.org>
 <525E840D.3040509@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525E840D.3040509@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 03:18:21PM +0300, Benny Halevy wrote:
> The nfs4.1 layout stateid is like any other stateid (open/lock/deleg)
> but it's life time is a bit different as it is not descending from the
> open stateid (though the protocol requires the client to use it
> to acquire the first layout for the file) and it is released via
> either LAYOUTRETURN or CLOSE (in the "return_on_close" case).
> The rules here are different enough from open/lock/deleg stateids that
> pnfsd needs special code to handle the management of the actual layout state
> under the layout stateid and manipulate it accordingly.

I'm not primarily ocnfused about the protocol even if that isn't all
that clear either.  I'm more worried about the code in and around
nfs4_find_create_layout_stateid.  I have looked a bit deeper into it
and I think the main problem is that struct nfs4_stid isn't refcounted
by itself, which really confused me expecting nfsd4_lookup_stateid
to return a reference to it.

> How many bits in the kernel address space are unique?
> I am under the impression that they'd differ mostly in their least significant bits anyway.
> Regardless, if it works well now then no reason to change it.

In theory the hash_ptr helper is there to take care exactly of that sort
of issue, in practice I can't see anything in there right now.

Before that becomes an issue we'll have to replace that dumb hash with a
more scalable data structure anyway.
