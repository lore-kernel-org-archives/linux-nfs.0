Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51978 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab3JZNUO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Oct 2013 09:20:14 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Wheeler Ric <ricwheeler@gmail.com>
CC: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Sat, 26 Oct 2013 13:20:12 +0000
Message-ID: <7C1323EE-D63F-4F93-A44D-E7DDB0C61BF0@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
 <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com>
In-Reply-To: <526A8D9A.8090008@gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 25, 2013, at 5:26 PM, Ric Wheeler <ricwheeler@gmail.com> wrote:

> On 10/25/2013 10:08 AM, J. Bruce Fields wrote:
>> On Thu, Oct 24, 2013 at 07:22:30PM +0200, Christoph Anton Mitterer wrote:
>>> On Thu, 2013-10-24 at 16:30 +0000, Myklebust, Trond wrote:
>>>> Those programs need to recompute the checksum data anyway in order to
>>>> verify and/or update it. Checksums that are computed by some third
>>>> party application have exactly zero value for integrity checking.
>>> No that's exactly the point,... the applications should _NOT_ set those
>>> checksums, especially not automagically (since then you'd never notice
>>> when just some application is buggy or writes/modifies when you don't
>>> expect it to do so).
>>> The idea is that there is on application (in my case it's just a
>>> script), which sets the integrity data and verifies it.
>>> 
>>> This works very well for e.g. large data archives, where you most of the
>>> time (but not always) only read files, write new files or move around
>>> existing ones - but only rarely modify existing file's contents.
>>> 
>>> 
>>> I do this already like that on local filesystems, which works very
>>> nicely with XATTRs... but now I want to move this on a central data
>>> cluster (where clients connect to via NFS)... and here the problems
>>> start... when I add new data to the archive (from the clients) I cannot
>>> have XATTRs attached, nor can I verify them form the clients.
>> Can you give any more details about your use case?  (E.g. is there an
>> article describing this system somewhere?)
>> 
>> Just curious.--b.
>> 
> 
> I think that having xattrs in NFS would be very useful over time. A lot of user space tools have been made aware of them, we are certainly lagging all (almost all?) local file system here and it can cause a data loss when you copy a file from a local file system to an NFS server.
> 
> It certainly violates the principle of least surprise that the xattrs are lost when move through NFS!

The _problem_ is that xattrs are a system call interface. Setting the xattrs in the "system", "security", or even the "trusted" namespace have undocumented side effects. There are very good security reasons why NFS doesn't have an IOCTL rpc call for executing arbitrary ioctls on the NFS server. Those same reasons apply to xattr.

> Typical use cases I have seen include storing things like metadata that tracks what application created the file, tags to let you know when the last time the file was verified by a data integrity scrubber, tags that hold a checksum/crypto has of the file contents along with the date of that signature.

Standardise those xattrs, and we can export them specifically as part of the NFSv4 spec.

> Doing a file system service does not mean that we have to be personally interested in all of the odd things that our users might use features for, but at this point, xattrs are water under the bridge and NFS not supporting them makes us look bad :)

I'd rather look bad for not supporting a broken filesystem feature than have to deal with the abiove mentioned side-effects. Until the xattr interface is properly documented and standardised so that it can be exported safely, it should be treated as a unexportable, in the same way we treat procfs and sysfs.

Cheers
  Trond