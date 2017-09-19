Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50502 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdISPsU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Sep 2017 11:48:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170919151051.GS9536@redhat.com>
Date: Tue, 19 Sep 2017 11:48:10 -0400
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
References: <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com> <20170914173730.GD4673@fieldses.org> <20170915131224.GC14994@stefanha-x1.localdomain> <20170915133145.GA23557@fieldses.org> <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com> <20170915164223.GE23557@fieldses.org> <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com> <20170918180927.GD12759@stefanha-x1.localdomain> <20170919093140.GF9536@redhat.com> <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com> <20170919151051.GS9536@redhat.com>
To: "Daniel P. Berrange" <berrange@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 19, 2017, at 11:10 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
> 
> On Tue, Sep 19, 2017 at 10:35:49AM -0400, Chuck Lever wrote:
>> 
>>> On Sep 19, 2017, at 5:31 AM, Daniel P. Berrange <berrange@redhat.com> wrote:
>>> 
>>> On Mon, Sep 18, 2017 at 07:09:27PM +0100, Stefan Hajnoczi wrote:
>>>> There are 2 main use cases:
>>>> 
>>>> 1. Easy file sharing between host & guest
>>>> 
>>>>  It's true that a disk image can be used but that's often inconvenient
>>>>  when the data comes in individual files.  Making throwaway ISO or
>>>>  disk image from those files requires extra disk space, is slow, etc.
>>> 
>>> More critically, it cannot be easily live-updated for a running guest.
>>> Not all of the setup data that the hypervisor wants to share with the
>>> guest is boot-time only - some may be access repeatedly post boot &
>>> have a need to update it dynamically. Currently OpenStack can only
>>> satisfy this if using its network based metadata REST service, but
>>> many cloud operators refuse to deploy this because they are not happy
>>> with the guest and host sharing a LAN, leaving only the virtual disk
>>> option which can not support dynamic update.
>> 
>> Hi Daniel-
>> 
>> OK, but why can't the REST service run on VSOCK, for instance?
> 
> That is a possibility, though cloud-init/OpenStack maintainers are
> reluctant to add support for new features for the metadata REST
> service, because the spec being followed is defined by Amazon (as
> part of EC2), not by OpenStack. So adding new features would be
> effectively forking the spec by adding stuff Amazon doesn't (yet)
> support - this is why its IPv4 only, with no IPv6 support too,
> as Amazon has not defined a standardized IPv6 address for the
> metadata service at this time.

You guys are asking the NFS community for a similar kind of
specification change here. We would prefer that you seek that change
with the relevant authority (the IETF) first before trying to merge
an implementation of it.

As a first step we have to define RPC operation on VSOCK transports.
That's the smallest piece of it. Dealing with some of the NFS issues
(like, what happens to filehandles and lock state during a live
guest migration) is an even larger challenge.

Sorry, but you can't avoid one interoperability problem (Amazon)
by introducing another (NFS).


>> How is VSOCK different than guests and hypervisor sharing a LAN?
> 
> VSOCK requires no guest configuration, it won't be broken accidentally
> by NetworkManager (or equivalent), it won't be mistakenly blocked by
> guest admin/OS adding "deny all" default firewall policy. Similar
> applies on the host side, and since there's separation from IP networking,
> there is no possibility of the guest ever getting a channel out to the
> LAN, even if the host is mis-configurated.

We don't seem to have configuration fragility problems with other
deployments that scale horizontally.

IMO you should focus on making IP reliable rather than trying to
move familiar IP-based services to other network fabrics.

Or, look at existing transports:

 - We have an RPC-over-named-pipes transport that could be used

 - NFS/RDMA with a virtual RoCE adapter would also work, and
   could perform better than something based on TCP streams


>> Would it be OK if the hypervisor and each guest shared a virtual
>> point-to-point IP network?
> 
> No - per above / below text
> 
>> Can you elaborate on "they are not happy with the guests and host
>> sharing a LAN" ?
> 
> The security of the host management LAN is so critical to the cloud,
> that they're not willing to allow any guest network interface to have
> an IP visible to/from the host, even if it were locked down with
> firewall rules. It is just one administrative mis-configuration
> away from disaster.

For the general case of sharing NFS files, I'm not suggesting that
the guest and hypervisor share a management LAN for NFS. Rather,
the suggestion is to have a separate point-to-point storage area
network that has narrow trust relationships.


>>> If the admin takes any live snapshots of the guest, then this throwaway
>>> disk image has to be kept around for the lifetime of the snapshot too.
>>> We cannot just throw it away & re-generate it later when restoring the
>>> snapshot, because we canot guarantee the newly generated image would be
>>> byte-for-byte identical to the original one we generated due to possible
>>> changes in mkfs related tools.
>> 
>> Seems like you could create a loopback mount of a small file to
>> store configuration data. That would consume very little local
>> storage. I've done this already in the fedfs-utils-server package,
>> which creates small loopback mounted filesystems to contain FedFS
>> domain root directories, for example.
>> 
>> Sharing the disk serially is a little awkward, but not difficult.
>> You could use an automounter in the guest to grab that filesystem
>> when needed, then release it after a period of not being used.
> 
> 
> With QEMU's previous 9p-over-virtio filesystem support people have
> built tools which run virtual machines where the root FS is directly
> running against a 9p share from the host filesystem. It isn't possible
> to share the host filesystem's /dev/sda (or whatever) to the guest
> because its a holding a non-cluster filesystem so can't be mounted
> twice. Likewise you don't want to copy the host filesystems entire
> contents into a block device and mount that, as its simply impratical
> 
> With 9p-over-virtio, or NFS-over-VSOCK, we can execute commands
> present in the host's filesystem, sandboxed inside a QEMU guest
> by simply sharing the host's '/' FS to the guest and have the
> guest mount that as its own / (typically it would be read-only,
> and then a further FS share would be added for writeable areas).
> For this to be reliable we can't use host IP networking because
> there's too many ways for that to fail, and if spawning the sandbox
> as non-root we can't influence the host networking setup at all.
> Currently it uses 9p-over-virtio for this reason, which works
> great, except that distros hate the idea of supporting a 9p
> filesystem driver in the kernel - a NFS driver capable of
> running over virtio is a much smaller incremental support
> burden.

OK, so this is not the use case that has been described before.
This is talking about more than just configuration information.

Let's call this use case "NFSROOT without IP networking".

Still, the practice I was aware of is that OpenStack would
provide a copy of a golden root filesystem to the hypervisor,
who would then hydrate that on its local storage, and provide
it to a new guest as a virtual disk.

In terms of storage management, I still don't see much benefit
in using local NFS storage for this use case (except for the
real-time sharing of configuration changes).


>>>>  From a user perspective it's much nicer to point to a directory and
>>>>  have it shared with the guest.
>>>> 
>>>> 2. Using NFS over AF_VSOCK as an interface for a distributed file system
>>>>  like Ceph or Gluster.
>>>> 
>>>>  Hosting providers don't necessarily want to expose their distributed
>>>>  file system directly to the guest.  An NFS frontend presents an NFS
>>>>  file system to the guest.  The guest doesn't have access to the
>>>>  distributed file system configuration details or network access.  The
>>>>  hosting provider can even switch backend file systems without
>>>>  requiring guest configuration changes.
>> 
>> Notably, NFS can already support hypervisor file sharing and
>> gateway-ing to Ceph and Gluster. We agree that those are useful.
>> However VSOCK is not a pre-requisite for either of those use
>> cases.
> 
> This again requires that the NFS server which runs on the management LAN
> be visible to the guest network. So this hits the same problem above with
> cloud providers wanting those networks completely separate.

No, it doesn't require using the management LAN at all.


> The desire from OpenStack is to have an NFS server on the compute host,
> which exposes the Ceph filesystem to the guest over VSOCK

The use of VSOCK is entirely separate from the existence of an
NFS service on the hypervisor, since NFS can already gateway
Ceph. Let's just say that the requirement is access to an NFS
service without IP networking.

So, thanks for responding, Dan, this has cleared up some
troublesome details. But I think more discussion is needed.



--
Chuck Lever



