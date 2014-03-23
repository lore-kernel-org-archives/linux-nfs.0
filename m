Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47877 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbaCWBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1WRWxb-0002p8-A1
	for linux-nfs@vger.kernel.org; Sat, 22 Mar 2014 21:12:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd4 xdr encoding fixes
Date: Sat, 22 Mar 2014 21:11:31 -0400
Message-Id: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a collection of fixes for the NFS server's encoding of NFSv4
compounds, along with a few tangentially related cleanups and bugfixes I
noticed along the way.

The basic problem is that we've always assumed an rpc reply is either

	- "small" (much less than a page), or
	- looks like a read (a bunch of data with a little bit at the
	  beginning and the end).

That assumption has allowed us to cover the most important cases without
having to deal with some annoying details like how to encode arbitrary
data across a page boundary, but: 

	- The inability to encode attributes of more than a page annoys
	  some people who would like to get and set extraordinarily long
	  ACLs.

	- The inability to encode attributes that cross page boundaries
	  also means we can't return more than a page of readdir data at
	  a time, limiting readdir performance on large directories.

	- The NFSv4 protocol doesn't really allow us to place these
	  sorts of arbitrary limits on the types of compounds we handle.
	  (Well, 4.0 is a bit fuzzy on this point, but 4.1 I think
	  definitely considers it a bug if a server won't handle, e.g.,
	  multiple read ops in a compound.)  This hasn't been an issue
	  because most of these exotic compounds aren't really useful to
	  clients.  But maybe future clients will find a use for some of
	  them--in which case we'd prefer not to make the work around a
	  server that doesn't meet the spec.

So, the main goal is to fix those limitations.  We also get to share a
little more code with the client.

I was hoping to merge this for 3.15, but I'm cutting this a little close
now, so we'll see.  I'll merge whatever's ready.

Further work may include:

	- writing more pynfs tests for exotic compounds and odd corner
	  cases,
	- auditing the annoying nfsd4_*_rsize() functions, which we now
	  depend on for more things,
	- improving our (currently very sloppy) estimate of how much
	  space we need for krb5i/krb5p to checksum/encrypt the result.
	- sharing some of this with the v2/v3 code (especially in the
	  read and readdir cases),
	- allow rpc's whose call and reply are both very large (our one
	  remaining dubious limit on compounds, though again something
	  clients seem unlikely to notice for now),
	- on the decode side, eliminating the existing macros and
	  sharing more helpers with the client.

--b.

