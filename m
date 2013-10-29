Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9006 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825Ab3J2AxL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 20:53:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Anand Avati <aavati@redhat.com>,
        Dr Fields James Bruce <bfields@redhat.com>,
        Wheeler Ric <rwheeler@redhat.com>,
        "Mailing List Linux NFS" <linux-nfs@vger.kernel.org>,
        Dickson Steve <steved@redhat.com>
Subject: Re: XATTRs in NFS?
Date: Tue, 29 Oct 2013 00:53:09 +0000
Message-ID: <05E44689-68BD-43AE-A5C8-409883E84227@netapp.com>
References: <20131028180838.GG31322@fieldses.org>
 <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com>
 <1383007167.8774.52.camel@heisenberg.scientia.net>
In-Reply-To: <1383007167.8774.52.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2013, at 8:39 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> I might add a similar use case which we have at the faculty respectively
> the local supercomputing centre:
> 
> What we have there is big cluster filesystems (used to be Lustre but
> nowadays I think they use GPFS).
> There are custom (i.e. local) applications where XATTRs are used to
> attach some metadata to files, which works fine in these cluster
> filesystems since they have native support.
> 
> Now what they sometimes do (AFAIU) is, export the cluster fs via NFS, to
> nodes which don't have support for the cluster fs itself (sometimes the
> OS is simply too old, but one common use case is also, that they simply
> don't allow direct mounts outside of e.g. the super computer).
> 
> At that point, NFS looses the XATTRs.

Why do these nodes need access to the xattrs? What applications are they running that need them? Why can't those applications run on the native cluster instead?

Trond