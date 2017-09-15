Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49848 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdION7z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Sep 2017 09:59:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170915133145.GA23557@fieldses.org>
Date: Fri, 15 Sep 2017 06:59:45 -0700
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Message-Id: <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
References: <20170913102650.10377-1-stefanha@redhat.com> <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com> <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com> <20170914173730.GD4673@fieldses.org> <20170915131224.GC14994@stefanha-x1.localdomain> <20170915133145.GA23557@fieldses.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 15, 2017, at 6:31 AM, J . Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Sep 15, 2017 at 02:12:24PM +0100, Stefan Hajnoczi wrote:
>> On Thu, Sep 14, 2017 at 01:37:30PM -0400, J . Bruce Fields wrote:
>>> On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
>>>> On 09/14/2017 11:39 AM, Steve Dickson wrote:
>>>>> Hello
>>>>> 
>>>>> On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
>>>>>> v3:
>>>>>> * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
>>>>>> * Added clientaddr autodetection in mount.nfs(8)
>>>>>> * Replaced #ifdefs with a single vsock.h header file
>>>>>> * Tested nfsd serving both IPv4 and vsock at the same time
>>>>> Just curious as to the status of the kernel patches... Are
>>>>> they slated for any particular release?
>>>> Maybe I should have read the thread before replying ;-) 
>>>> 
>>>> I now see the status of the patches... not good!  8-)
>>> 
>>> To be specific, the code itself is probably fine, it's just that nobody
>>> on the NFS side seems convinced that NFS/VSOCK is necessary.
>> 
>> Yes, the big question is whether the Linux NFS maintainers can see this
>> feature being merged.  It allows host<->guest file sharing in a way that
>> management tools can automate.
>> 
>> I have gotten feedback multiple times that NFS over TCP/IP is not an
>> option for management tools like libvirt to automate.
> 
> We're having trouble understanding why this is.

I'm also having trouble understanding why NFS is a better solution
in this case than a virtual disk, which does not require any net-
working to be configured. What exactly is expected to be shared
between the hypervisor and each guest?

I do understand the use cases for a full-featured NFS server in
the hypervisor, but not why it needs to be zero-config.


> Maybe it would help if you could put us directly in touch with the
> sources of those feedback?
> 
> --b.
> 
>> They want
>> something that is both zero-configuration and not prone to breakage
>> inside the guest.  AF_VSOCK has those qualities.
>> 
>> Can you give a verdict on NFS over AF_VSOCK as Linux NFS maintainers?
>> 
>> If the verdict is yes, then I'll submit the kernel patch series and get
>> to work on netid registration.  If no, then everyone can move on and
>> I'll figure out what to do next.
>> 
>> The latest kernel code is here:
>> https://github.com/stefanha/linux/tree/vsock-nfsd
>> 
>> Stefan
>> 
>> PS: I removed Neil Brown from CC because he requested not to be included
>> on this patch series.

--
Chuck Lever



