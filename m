Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332Ab3AWWzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:40 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMtePW009534
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: draft server xdr rewrite
Date: Wed, 23 Jan 2013 17:55:31 -0500
Message-Id: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The following patches fix two problems:
	- The server can't support ACLs longer than 4k.
	- The server can't return more than 4k of readdir data per rpc,
	  limiting performance on large directories.

At fault in both cases is the compound xdr encoding, which is unable to
deal with page boundaries.

Simplifying slightly:

I want to be able to write server code something like:

	__be32 *p;

	p = reserve_space(12)
		return nfserr_resource;
	write64(&p, bignum);
	write32(&p, smallernum);
	p = reserve_space(xdr, &p, 4+namelen);
	if (!p)
		return nfserr_resource;
	write32(&p, namelen);
	writemem(&p, name);
	...

and have page boundaries handled under the covers.

The following patches do that by replacing the __be32 * by
approximately:

	struct svcxdr_ptr {
		__be32 *p;
		struct page **next_page;
	}

with next_page a pointer into an array of available pages.  The encoders
can then traverse to the next page with something like:

	ptr->p = page_address(*ptr->next_page++);

We also define a svcxdr_stream to keep track of various state.  That and
not wanting a struct as a return value makes the reserve_space above
into:

	if (!reserve_space(xdr, &p, 12))
		return nfserr_resource;
	...

Seem reasonable?

If so, I plan to convert the rest of the v4 encoding.  (After revising
these patches--e.g. readdir still has a few problems I want to fix.  But
this does pass the usual connectathon and pynfs testing already.)

--b.

J. Bruce Fields (7):
  nfsd4: reserve space for integrity/privacy
  nfsd4: simplify nfsd4_encode_fattr interface slightly
  nfsd4: nfsd4_encode_fattr cleanup
  nfsd4: encode_rdattr_error cleanup
  nfsd4: rewrite xdr encoding of attributes
  nfsd4: track maximum bytes
  nfsd4: readdir encoding

 fs/nfsd/nfs4proc.c |  17 +-
 fs/nfsd/nfs4xdr.c  | 892 +++++++++++++++++++++++++++++++++--------------------
 fs/nfsd/xdr4.h     |  24 +-
 3 files changed, 588 insertions(+), 345 deletions(-)

-- 
1.7.11.7

