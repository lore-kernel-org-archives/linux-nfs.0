Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44558 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdIMSWc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Sep 2017 14:22:32 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [nfsv4] [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CADaq8jd2VaHUX=9rVbG41tTPj+9R8Grkjnaoh1hfKv8sVn5-GA@mail.gmail.com>
Date: Wed, 13 Sep 2017 11:21:36 -0700
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Steve Dickson <steved@redhat.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        NeilBrown <neilb@suse.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>
Message-Id: <EE7BAC64-DE4E-4A46-B692-08C0D7FE9D72@oracle.com>
References: <20170913102650.10377-1-stefanha@redhat.com> <20170913162111.GA14389@infradead.org> <CADaq8jd2VaHUX=9rVbG41tTPj+9R8Grkjnaoh1hfKv8sVn5-GA@mail.gmail.com>
To: David Noveck <davenoveck@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 13, 2017, at 11:18 AM, David Noveck <davenoveck@gmail.com> wrote:
> 
> > and how to ask IESG to assign it?
> 
> The way to get the IESG to assign it would be to write an RFC and get it approved as a Proposed Standard but I don't think you need to do that.  There is a portion of the netid registry that is assigned on a first-come-first-served basis (see RFCs 5665 and 5226) and if you are OK with that, the IESG doesn't have to be involved.  You simply have to ask IANA to assign it, providing the information (pretty limited) mentioned in those RFCs.

Stefan also needs to define a universal address format.

And somewhere we need to specify how this new RPC transport works.
In hand-waving mode, it's basically TCP (with the same connection
and record-marking semantics) but using a different address family.

So it may not be as simple as a single IANA action.


> On Wed, Sep 13, 2017 at 12:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Please get your VSOCK NFS transport into the ietf NFSv4 working group
> first before moving forward with Linux support - we should not implement
> non-standardized extensions.
> 
> On Wed, Sep 13, 2017 at 11:26:36AM +0100, Stefan Hajnoczi wrote:
> >  * The last revision was somewhat controversial because it's already possible
> >    to share files between a hypervisor and virtual machine using TCP/IP, so why
> >    add AF_VSOCK support to the stack?  TCP/IP based solutions require the
> >    virtual machine administrator to be involved in the configuration and are
> >    therefore not suitable for automatic management by OpenStack, oVirt, etc.
> >    Maintainers, is this feature acceptable?
> >
> >  * Need advice on netid: is there agreement to use "tcpv" instead of "vsock" as
> >    Chuck Lever suggested and how to ask IESG to assign it?
> >
> > The AF_VSOCK address family allows virtual machines to communicate with the
> > hypervisor using a zero-configuration transport.  KVM, VMware, and Hyper-V
> > hypervisors support AF_VSOCK and it was first introduced in Linux 3.9.
> >
> > This patch series adds AF_VSOCK support to mount.nfs(8) and rpc.nfsd(8).  To
> > mount an export from the hypervisor (CID 2):
> >
> >   # mount.nfs 2:/srv/vm01 /mnt -o proto=vsock
> >
> > To serve exports over vsock port 2049:
> >
> >   # nfsd ... --vsock 2049
> >
> > This series extends exports(5) syntax to handle vsock:<CID> or vsock:*.  For
> > example, the guest with CID 3 can be given access using vsock:3.
> >
> > nfsd can export over IPv4/IPv6 and vsock at the same time.  See the changes to
> > exports.man, nfs.man, and nfsd.man in the patches for syntax details.
> >
> > NFSv4 and later are supported.
> >
> > The code is also available here:
> > https://github.com/stefanha/nfs-utils/tree/vsock-nfsd
> >
> > The latest kernel patches are available here:
> > https://github.com/stefanha/linux/tree/vsock-nfsd
> >
> > Stefan Hajnoczi (14):
> >   mount: don't use IPPROTO_UDP for address resolution
> >   nfs-utils: add vsock.h
> >   nfs-utils: add AF_VSOCK support to sockaddr.h
> >   mount: present AF_VSOCK addresses
> >   mount: accept AF_VSOCK in nfs_verify_family()
> >   mount: generate AF_VSOCK clientaddr
> >   getport: recognize "vsock" netid
> >   mount: AF_VSOCK address parsing
> >   exportfs: introduce host_freeaddrinfo()
> >   exportfs: add AF_VSOCK address parsing and printing
> >   exportfs: add AF_VSOCK support to set_addrlist()
> >   exportfs: add support for "vsock:" exports(5) syntax
> >   nfsd: add --vsock (-v) option to nfsd
> >   tests: add "vsock:" exports(5) test case
> >
> >  tests/Makefile.am          |   3 +-
> >  support/include/exportfs.h |   4 ++
> >  support/include/sockaddr.h |  18 +++++
> >  support/include/vsock.h    |  59 +++++++++++++++++
> >  utils/nfsd/nfssvc.h        |   1 +
> >  support/export/client.c    |   8 +--
> >  support/export/hostname.c  | 161 +++++++++++++++++++++++++++++++++++++++++++--
> >  support/nfs/getport.c      |  16 +++--
> >  utils/exportfs/exportfs.c  |  42 ++++++++++--
> >  utils/mount/network.c      |  37 ++++++++++-
> >  utils/mount/stropts.c      |  61 ++++++++++++++---
> >  utils/mountd/auth.c        |   2 +-
> >  utils/mountd/cache.c       |  10 +--
> >  utils/mountd/mountd.c      |   4 +-
> >  utils/mountd/rmtab.c       |   2 +-
> >  utils/nfsd/nfsd.c          |  18 ++++-
> >  utils/nfsd/nfssvc.c        |  62 +++++++++++++++++
> >  configure.ac               |   3 +
> >  tests/t0002-vsock-basic.sh |  53 +++++++++++++++
> >  utils/exportfs/exports.man |  12 +++-
> >  utils/mount/nfs.man        |  20 ++++--
> >  utils/nfsd/nfsd.man        |   4 ++
> >  22 files changed, 552 insertions(+), 48 deletions(-)
> >  create mode 100644 support/include/vsock.h
> >  create mode 100755 tests/t0002-vsock-basic.sh
> >
> > --
> > 2.13.5
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4

--
Chuck Lever



