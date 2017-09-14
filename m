Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751445AbdINP4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 11:56:02 -0400
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Steve Dickson <SteveD@RedHat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
Message-ID: <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
Date: Thu, 14 Sep 2017 11:55:51 -0400
MIME-Version: 1.0
In-Reply-To: <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/14/2017 11:39 AM, Steve Dickson wrote:
> Hello
> 
> On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
>> v3:
>>  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
>>  * Added clientaddr autodetection in mount.nfs(8)
>>  * Replaced #ifdefs with a single vsock.h header file
>>  * Tested nfsd serving both IPv4 and vsock at the same time
> Just curious as to the status of the kernel patches... Are
> they slated for any particular release?
Maybe I should have read the thread before replying ;-) 

I now see the status of the patches... not good!  8-)

steved
> 
> steved.
> 
>>
>> Status:
>>
>>  * The last revision was somewhat controversial because it's already possible
>>    to share files between a hypervisor and virtual machine using TCP/IP, so why
>>    add AF_VSOCK support to the stack?  TCP/IP based solutions require the
>>    virtual machine administrator to be involved in the configuration and are
>>    therefore not suitable for automatic management by OpenStack, oVirt, etc.
>>    Maintainers, is this feature acceptable?
>>
>>  * Need advice on netid: is there agreement to use "tcpv" instead of "vsock" as
>>    Chuck Lever suggested and how to ask IESG to assign it?
>>
>> The AF_VSOCK address family allows virtual machines to communicate with the
>> hypervisor using a zero-configuration transport.  KVM, VMware, and Hyper-V
>> hypervisors support AF_VSOCK and it was first introduced in Linux 3.9.
>>
>> This patch series adds AF_VSOCK support to mount.nfs(8) and rpc.nfsd(8).  To
>> mount an export from the hypervisor (CID 2):
>>
>>   # mount.nfs 2:/srv/vm01 /mnt -o proto=vsock
>>
>> To serve exports over vsock port 2049:
>>
>>   # nfsd ... --vsock 2049
>>
>> This series extends exports(5) syntax to handle vsock:<CID> or vsock:*.  For
>> example, the guest with CID 3 can be given access using vsock:3.
>>
>> nfsd can export over IPv4/IPv6 and vsock at the same time.  See the changes to
>> exports.man, nfs.man, and nfsd.man in the patches for syntax details.
>>
>> NFSv4 and later are supported.
>>
>> The code is also available here:
>> https://github.com/stefanha/nfs-utils/tree/vsock-nfsd
>>
>> The latest kernel patches are available here:
>> https://github.com/stefanha/linux/tree/vsock-nfsd
>>
>> Stefan Hajnoczi (14):
>>   mount: don't use IPPROTO_UDP for address resolution
>>   nfs-utils: add vsock.h
>>   nfs-utils: add AF_VSOCK support to sockaddr.h
>>   mount: present AF_VSOCK addresses
>>   mount: accept AF_VSOCK in nfs_verify_family()
>>   mount: generate AF_VSOCK clientaddr
>>   getport: recognize "vsock" netid
>>   mount: AF_VSOCK address parsing
>>   exportfs: introduce host_freeaddrinfo()
>>   exportfs: add AF_VSOCK address parsing and printing
>>   exportfs: add AF_VSOCK support to set_addrlist()
>>   exportfs: add support for "vsock:" exports(5) syntax
>>   nfsd: add --vsock (-v) option to nfsd
>>   tests: add "vsock:" exports(5) test case
>>
>>  tests/Makefile.am          |   3 +-
>>  support/include/exportfs.h |   4 ++
>>  support/include/sockaddr.h |  18 +++++
>>  support/include/vsock.h    |  59 +++++++++++++++++
>>  utils/nfsd/nfssvc.h        |   1 +
>>  support/export/client.c    |   8 +--
>>  support/export/hostname.c  | 161 +++++++++++++++++++++++++++++++++++++++++++--
>>  support/nfs/getport.c      |  16 +++--
>>  utils/exportfs/exportfs.c  |  42 ++++++++++--
>>  utils/mount/network.c      |  37 ++++++++++-
>>  utils/mount/stropts.c      |  61 ++++++++++++++---
>>  utils/mountd/auth.c        |   2 +-
>>  utils/mountd/cache.c       |  10 +--
>>  utils/mountd/mountd.c      |   4 +-
>>  utils/mountd/rmtab.c       |   2 +-
>>  utils/nfsd/nfsd.c          |  18 ++++-
>>  utils/nfsd/nfssvc.c        |  62 +++++++++++++++++
>>  configure.ac               |   3 +
>>  tests/t0002-vsock-basic.sh |  53 +++++++++++++++
>>  utils/exportfs/exports.man |  12 +++-
>>  utils/mount/nfs.man        |  20 ++++--
>>  utils/nfsd/nfsd.man        |   4 ++
>>  22 files changed, 552 insertions(+), 48 deletions(-)
>>  create mode 100644 support/include/vsock.h
>>  create mode 100755 tests/t0002-vsock-basic.sh
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
