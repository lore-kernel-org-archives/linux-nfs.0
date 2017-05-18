Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21645 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753540AbdERO2X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2017 10:28:23 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: EXCHANGE_ID with same network address but different server owner
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170518133441.GC4155@stefanha-x1.localdomain>
Date: Thu, 18 May 2017 10:28:10 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
References: <20170512132721.GA654@stefanha-x1.localdomain> <20170512143410.GC17983@parsley.fieldses.org> <1494601295.10434.1.camel@primarydata.com> <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com> <20170515144306.GB16013@stefanha-x1.localdomain> <20170515160248.GD9697@parsley.fieldses.org> <20170516131142.GA12711@fieldses.org> <20170518133441.GC4155@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 18, 2017, at 9:34 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> On Tue, May 16, 2017 at 09:11:42AM -0400, J. Bruce Fields wrote:
>> I think you explained this before, perhaps you could just offer a
>> pointer: remind us what your requirements or use cases are especially
>> for VM migration?
> 
> The NFS over AF_VSOCK configuration is:
> 
> A guest running on host mounts an NFS export from the host.  The NFS
> server may be kernel nfsd or an NFS frontend to a distributed storage
> system like Ceph.  A little more about these cases below.
> 
> Kernel nfsd is useful for sharing files.  For example, the guest may
> read some files from the host when it launches and/or it may write out
> result files to the host when it shuts down.  The user may also wish to
> share their home directory between the guest and the host.
> 
> NFS frontends are a different use case.  They hide distributed storage
> systems from guests in cloud environments.  This way guests don't see
> the details of the Ceph, Gluster, etc nodes.  Besides benefiting
> security it also allows NFS-capable guests to run without installing
> specific drivers for the distributed storage system.  This use case is
> "filesystem as a service".
> 
> The reason for using AF_VSOCK instead of TCP/IP is that traditional
> networking configuration is fragile.  Automatically adding a dedicated
> NIC to the guest and choosing an IP subnet has a high chance of
> conflicts (subnet collisions, network interface naming, firewall rules,
> network management tools).  AF_VSOCK is a zero-configuration
> communications channel so it avoids these problems.
> 
> On to migration.  For the most part, guests can be live migrated between
> hosts without significant downtime or manual steps.  PCI passthrough is
> an example of a feature that makes it very hard to live migrate.  I hope
> we can allow migration with NFS, although some limitations may be
> necessary to make it feasible.
> 
> There are two NFS over AF_VSOCK migration scenarios:
> 
> 1. The files live on host H1 and host H2 cannot access the files
>   directly.  There is no way for an NFS server on H2 to access those
>   same files unless the directory is copied along with the guest or H2
>   proxies to the NFS server on H1.

Having managed (and shared) storage on the physical host is
awkward. I know some cloud providers might do this today by
copying guest disk images down to the host's local disk, but
generally it's not a flexible primary deployment choice.

There's no good way to expand or replicate this pool of
storage. A backup scheme would need to access all physical
hosts. And the files are visible only on specific hosts.

IMO you want to treat local storage on each physical host as
a cache tier rather than as a back-end tier.


> 2. The files are accessible from both host H1 and host H2 because they
>   are on shared storage or distributed storage system.  Here the
>   problem is "just" migrating the state from H1's NFS server to H2 so
>   that file handles remain valid.

Essentially this is the re-export case, and this makes a lot
more sense to me from a storage administration point of view.

The pool of administered storage is not local to the physical
hosts running the guests, which is how I think cloud providers
would prefer to operate.

User storage would be accessible via an NFS share, but managed
in a Ceph object (with redundancy, a common high throughput
backup facility, and secure central management of user
identities).

Each host's NFS server could be configured to expose only the
the cloud storage resources for the tenants on that host. The
back-end storage (ie, Ceph) could operate on a private storage
area network for better security.

The only missing piece here is support in Linux-based NFS
servers for transparent state migration.


--
Chuck Lever



