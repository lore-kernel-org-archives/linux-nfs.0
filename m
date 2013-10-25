Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27092 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab3JYPcV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Oct 2013 11:32:21 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: XATTRs in NFS?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <526A8D9A.8090008@gmail.com>
Date: Fri, 25 Oct 2013 11:32:07 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs@vger.kernel.org
Message-Id: <8F7D9C5D-7E2F-459E-872C-2F4299943716@oracle.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net> <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com> <1382624000.6907.8.camel@heisenberg.scientia.net> <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com> <1382630468.6907.58.camel@heisenberg.scientia.net> <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com> <1382635350.6907.83.camel@heisenberg.scientia.net> <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com>
To: Ric Wheeler <ricwheeler@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 25, 2013, at 11:26 AM, Ric Wheeler <ricwheeler@gmail.com> wrote:

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
> 
> Typical use cases I have seen include storing things like metadata that tracks what application created the file, tags to let you know when the last time the file was verified by a data integrity scrubber, tags that hold a checksum/crypto has of the file contents along with the date of that signature.
> 
> Doing a file system service does not mean that we have to be personally interested in all of the odd things that our users might use features for, but at this point, xattrs are water under the bridge and NFS not supporting them makes us look bad :)

Trond's point is that it still would be a very heavy lift for us.

Local file systems can support whatever they like, since they are Linux-only.

NFS has to interoperate with other operating systems that may or may not support xattrs, or may have something that looks like an xattr, but really is subtly incompatible.

Therefore we must have a standard for storing and accessing xattrs locally (POSIX) and a standard for expressing their name and content on the wire (IETF NFS) before we can consider an implementation.

So we would like to see some very clear evidence that it's worth the effort.  Until then, Linux distributors are free to implement NFS xattr support outside the standard NFS protocol (like the Solaris NFSv3 ACL protocol) and support this themselves, perhaps as proof that "if you build it, they will come."

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




