Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:63712 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab3JYP0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Oct 2013 11:26:21 -0400
Received: by mail-qa0-f53.google.com with SMTP id k15so645588qaq.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Oct 2013 08:26:20 -0700 (PDT)
Message-ID: <526A8D9A.8090008@gmail.com>
Date: Fri, 25 Oct 2013 11:26:18 -0400
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs@vger.kernel.org
Subject: Re: XATTRs in NFS?
References: <1382560643.6924.12.camel@heisenberg.scientia.net> <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com> <1382624000.6907.8.camel@heisenberg.scientia.net> <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com> <1382630468.6907.58.camel@heisenberg.scientia.net> <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com> <1382635350.6907.83.camel@heisenberg.scientia.net> <20131025140846.GB20497@fieldses.org>
In-Reply-To: <20131025140846.GB20497@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/25/2013 10:08 AM, J. Bruce Fields wrote:
> On Thu, Oct 24, 2013 at 07:22:30PM +0200, Christoph Anton Mitterer wrote:
>> On Thu, 2013-10-24 at 16:30 +0000, Myklebust, Trond wrote:
>>> Those programs need to recompute the checksum data anyway in order to
>>> verify and/or update it. Checksums that are computed by some third
>>> party application have exactly zero value for integrity checking.
>> No that's exactly the point,... the applications should _NOT_ set those
>> checksums, especially not automagically (since then you'd never notice
>> when just some application is buggy or writes/modifies when you don't
>> expect it to do so).
>> The idea is that there is on application (in my case it's just a
>> script), which sets the integrity data and verifies it.
>>
>> This works very well for e.g. large data archives, where you most of the
>> time (but not always) only read files, write new files or move around
>> existing ones - but only rarely modify existing file's contents.
>>
>>
>> I do this already like that on local filesystems, which works very
>> nicely with XATTRs... but now I want to move this on a central data
>> cluster (where clients connect to via NFS)... and here the problems
>> start... when I add new data to the archive (from the clients) I cannot
>> have XATTRs attached, nor can I verify them form the clients.
> Can you give any more details about your use case?  (E.g. is there an
> article describing this system somewhere?)
>
> Just curious.--b.
>

I think that having xattrs in NFS would be very useful over time. A lot of user 
space tools have been made aware of them, we are certainly lagging all (almost 
all?) local file system here and it can cause a data loss when you copy a file 
from a local file system to an NFS server.

It certainly violates the principle of least surprise that the xattrs are lost 
when move through NFS!

Typical use cases I have seen include storing things like metadata that tracks 
what application created the file, tags to let you know when the last time the 
file was verified by a data integrity scrubber, tags that hold a checksum/crypto 
has of the file contents along with the date of that signature.

Doing a file system service does not mean that we have to be personally 
interested in all of the odd things that our users might use features for, but 
at this point, xattrs are water under the bridge and NFS not supporting them 
makes us look bad :)

Ric

