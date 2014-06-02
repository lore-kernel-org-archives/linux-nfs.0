Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:38411 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508AbaFBPFY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 11:05:24 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4178301.j9kWdGCRLC@wuerfel>
Date: Mon, 2 Jun 2014 11:04:23 -0400
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>,
        Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <8618458.1EVJCoVbkH@wuerfel> <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr> <4178301.j9kWdGCRLC@wuerfel>
To: Arnd Bergmann <arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2014, at 6:56 AM, Arnd Bergmann <arnd@arndb.de> wrote:

> On Sunday 01 June 2014 21:36:26 Nicolas Pitre wrote:
>> 
>>> For actually running kernels beyond 2038, the best idea I've seen so
>>> far is to disallow all broken code at compile time. I don't see
>>> a choice but to audit the entire kernel for invalid uses on both
>>> 32 and 64 bit in the next few years. A lot of code will get changed
>>> in the process so we can actually keep running 32-bit kernels and
>>> file systems, but other code will likely go away:
>>> 
>>> * any system calls that pass a time_t, timeval or timespec on
>>>  32-bit systems return -ENOSYS, to ensure all user land uses
>>>  the replacements we will put into place
>>> * The definition of 'time_t', 'timval' and 'timespec' can be hidden
>>>  from the kernel, and all code using it left out.
>>> * ext2 and ext3 file system code will have to be disabled, but that's
>>>  file since ext4 can mount old file systems.
>> 
>> Syscalls and libs can be "fixed".  Existing filesystem content might 
>> not.  So if you need to mount some old media in read-write mode after 
>> 2038 and that happens to content an ext2 or similarly limited filesystem 
>> then it'd better just "work".  Having the kernel refuse to modify the 
>> filesystem would be unacceptable.
> 
> I think you misunderstood what I suggested: the intent is to avoid
> seeing things break in 2038 by making them break much earlier. We have
> a solution for ext2 file systems, it's called ext4, and we just need
> to ensure that everybody knows they have to migrate eventually.
> 
> At some point before the mid 2030ies, you should no longer be able to
> build a kernel that has support for ext2 or any other module that will
> run into bugs later. Until then (rather sooner than later), I'd like
> to get to the point where you can choose whether to include those
> modules at build time or not, and then get everybody to turn off that
> option and fix the bugs they run into. You wouldn't need that for a
> 2014-generation long-term support disto (rhel 7, sles 12, debian 7,
> ubuntu 14.04, ...), but perhaps for the next generation, or the
> one after that.

I’m wondering what should be done about NFS. A solution for NFS should
match any scheme that is considered for local file systems, IMO.

NFSv2/3 timestamps are a pair of unsigned 32-bit values: one value for
seconds since midnight GMT Jan 1, 1970, and one value for nanoseconds.
(See the definition of nfstime3 in RFC 1813).

NFSv4 uses a signed 64-bit value where zero represents midnight UTC
on January 1, 1970, and an unsigned 32-bit value for nanoseconds. (See
the definition of nfstime4 in RFC 5661).

The NFSv4 protocol is probably not problematic, and NFSv3 should be out
of the picture by 2038. But if changes are planned for dealing _now_
with timestamp issues, compatibility with NFSv3 is a consideration.

It is already the case that, via NFSv3, the Linux NFS client transmits
timestamps earlier than 1970 as large positive numbers. Try this with
xfstests generic/258.

Maybe nfs3_proc_setattr() should recognize pre-epoch timestamps and
timestamps larger than can be represented in an unsigned 32-bit field
and return an immediate error to the requesting application (like EINVAL).

If the Linux NFS server encounters a local file with a timestamp that
cannot be represented via a u32, should it also return NFS3ERR_INVAL?

RFC 1813 does not provide guidance on the behavior nor does it suggest
a particular error status code. The Solaris 11 server appears to return
NFS3ERR_INVAL in this case.

An alternative would be to “cap” the timestamps transmitted via NFSv3 by
Linux, so that a pre-epoch timestamp is transmitted as zero, and a large
timestamp is transmitted as UINT_MAX.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



