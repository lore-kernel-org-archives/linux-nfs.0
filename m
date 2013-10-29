Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw02.dd24.net ([193.46.215.43]:39052 "EHLO
	mailgw02.dd24.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756755Ab3J2Ajj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 20:39:39 -0400
Message-ID: <1383007167.8774.52.camel@heisenberg.scientia.net>
Subject: Re: Fwd: Re: XATTRs in NFS?
From: Christoph Anton Mitterer <calestyo@scientia.net>
To: Anand Avati <aavati@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Ric Wheeler <rwheeler@redhat.com>,
        Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Steve Dickson <steved@redhat.com>
Date: Tue, 29 Oct 2013 01:39:27 +0100
In-Reply-To: <526EFFCC.2060506@redhat.com>
References: <20131028180838.GG31322@fieldses.org>
	 <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I might add a similar use case which we have at the faculty respectively
the local supercomputing centre:

What we have there is big cluster filesystems (used to be Lustre but
nowadays I think they use GPFS).
There are custom (i.e. local) applications where XATTRs are used to
attach some metadata to files, which works fine in these cluster
filesystems since they have native support.

Now what they sometimes do (AFAIU) is, export the cluster fs via NFS, to
nodes which don't have support for the cluster fs itself (sometimes the
OS is simply too old, but one common use case is also, that they simply
don't allow direct mounts outside of e.g. the super computer).

At that point, NFS looses the XATTRs.


Cheers,
Chris.

