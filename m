Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52602 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 12:39:13 -0400
Date: Wed, 20 Sep 2017 12:39:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170920163913.GE14329@fieldses.org>
References: <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
 <20170919204224.GA14329@fieldses.org>
 <37604438-9848-47CA-8884-8FD6292EAFC9@oracle.com>
 <20170920131641.GC14329@fieldses.org>
 <20170920145849.GF9947@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170920145849.GF9947@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 20, 2017 at 03:58:49PM +0100, Daniel P. Berrange wrote:
> FWIW, the current virtio-9p filesystem passthrough does not support
> migration and still has found usage in a number of scenarios where
> that limitation is not important. ClearContainers / libvirt sandbox
> are two which use 9p and don't care about migration. With this in mind,
> NFS-over-VSOCK would still be valuable even if the specification
> explicitly stated that live migration is not permitted.
> 
> If there was a specified way of supporting live migration with good
> semantics of the guest FS, then that would open up NFS-over-VSOCK to
> a wider range of use cases. Migration would likely be quite important
> to OpenStack usage, since live migration is the way cloud providers
> typically upgrade virt hosts to newer releases of OpenStack software.

Exactly what I was curious about, thanks!

--b.
