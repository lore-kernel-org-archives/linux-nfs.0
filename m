Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41495 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdIPPz3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Sep 2017 11:55:29 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170915164223.GE23557@fieldses.org>
Date: Sat, 16 Sep 2017 08:55:21 -0700
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
References: <20170913102650.10377-1-stefanha@redhat.com> <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com> <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com> <20170914173730.GD4673@fieldses.org> <20170915131224.GC14994@stefanha-x1.localdomain> <20170915133145.GA23557@fieldses.org> <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com> <20170915164223.GE23557@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 15, 2017, at 9:42 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Sep 15, 2017 at 06:59:45AM -0700, Chuck Lever wrote:
>> 
>>> On Sep 15, 2017, at 6:31 AM, J . Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Fri, Sep 15, 2017 at 02:12:24PM +0100, Stefan Hajnoczi wrote:
>>>> On Thu, Sep 14, 2017 at 01:37:30PM -0400, J . Bruce Fields wrote:
>>>>> On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
>>>>>> On 09/14/2017 11:39 AM, Steve Dickson wrote:
>>>>>>> Hello
>>>>>>> 
>>>>>>> On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
>>>>>>>> v3:
>>>>>>>> * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
>>>>>>>> * Added clientaddr autodetection in mount.nfs(8)
>>>>>>>> * Replaced #ifdefs with a single vsock.h header file
>>>>>>>> * Tested nfsd serving both IPv4 and vsock at the same time
>>>>>>> Just curious as to the status of the kernel patches... Are
>>>>>>> they slated for any particular release?
>>>>>> Maybe I should have read the thread before replying ;-) 
>>>>>> 
>>>>>> I now see the status of the patches... not good!  8-)
>>>>> 
>>>>> To be specific, the code itself is probably fine, it's just that nobody
>>>>> on the NFS side seems convinced that NFS/VSOCK is necessary.
>>>> 
>>>> Yes, the big question is whether the Linux NFS maintainers can see this
>>>> feature being merged.  It allows host<->guest file sharing in a way that
>>>> management tools can automate.
>>>> 
>>>> I have gotten feedback multiple times that NFS over TCP/IP is not an
>>>> option for management tools like libvirt to automate.
>>> 
>>> We're having trouble understanding why this is.
>> 
>> I'm also having trouble understanding why NFS is a better solution
>> in this case than a virtual disk, which does not require any net-
>> working to be configured. What exactly is expected to be shared
>> between the hypervisor and each guest?
> 
> They have said before there are uses for storage that's actually shared.
> (And I assume it would be mainly shared between guests rather than
> between guest and hypervisor?)

But this works today with IP-based networking. We certainly use
this kind of arrangement with OVM (Oracle's Xen-based hypervisor).
I agree NFS in the hypervisor is useful in interesting cases, but
I'm separating the need for a local NFS service with the need for
it to be zero-configuration.

The other use case that's been presented for NFS/VSOCK is an NFS
share that contains configuration information for each guest (in
particular, network configuration information). This is the case
I refer to above when I ask whether this can be done with a
virtual disk.

I don't see any need for concurrent access by the hypervisor and
guest, and one presumably should not share a guest's specific
configuration information with other guests. There would be no
sharing requirement, and therefore I would expect a virtual disk
filesystem would be adequate in this case and perhaps even
preferred, being more secure and less complex.


>> I do understand the use cases for a full-featured NFS server in
>> the hypervisor, but not why it needs to be zero-config.
> 
> "It" in that question refers to the client, not the server, right?

The hypervisor gets a VSOCK address too, which makes it zero-
configuration for any access via VSOCK transports from its guests.
I probably don't understand your question.

Note that an NFS server could also run in one of the guests, but
I assume that the VSOCK use cases are in particular about an NFS
service in the hypervisor that can be made available very early
in the life of a guest instance. I make that guess because all
the guests have the same VSOCK address (as I understand it), so
that would make it difficult to discover and access an NFS/VSOCK
service in another guest.


--
Chuck Lever



