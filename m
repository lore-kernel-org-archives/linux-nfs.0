Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42144 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858Ab2HIQlB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 12:41:01 -0400
Received: by pbbrr13 with SMTP id rr13so1151360pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 09:41:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344529783.25447.32.camel@lade.trondhjem.org>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
 <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
 <1344522979.23523.2.camel@lade.trondhjem.org> <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>
 <1344526780.25447.6.camel@lade.trondhjem.org> <CA+a=Yy5zrdt6xAHFhXk9KypjGRvy2CbWC2DcNnudPDQ4ni=urA@mail.gmail.com>
 <1344529783.25447.32.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 10 Aug 2012 00:40:40 +0800
Message-ID: <CA+a=Yy7KpdGYBDSENnd7cNtqvapNhu4L4cAgidDhdwvp46WvTg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2012 at 12:29 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-08-10 at 00:22 +0800, Peng Tao wrote:
>> On Thu, Aug 9, 2012 at 11:39 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Thu, 2012-08-09 at 23:01 +0800, Peng Tao wrote:
>> >> On Thu, Aug 9, 2012 at 10:36 PM, Myklebust, Trond
>> >> <Trond.Myklebust@netapp.com> wrote:
>> >> > On Thu, 2012-08-09 at 22:30 +0800, Peng Tao wrote:
>> >> >> On Thu, Aug 9, 2012 at 4:21 AM, Trond Myklebust
>> >> >> <Trond.Myklebust@netapp.com> wrote:
>> >> >> > Ever since commit 0a57cdac3f (NFSv4.1 send layoutreturn to fence
>> >> >> > disconnected data server) we've been sending layoutreturn calls
>> >> >> > while there is potentially still outstanding I/O to the data
>> >> >> > servers. The reason we do this is to avoid races between replayed
>> >> >> > writes to the MDS and the original writes to the DS.
>> >> >> >
>> >> >> > When this happens, the BUG_ON() in nfs4_layoutreturn_done can
>> >> >> > be triggered because it assumes that we would never call
>> >> >> > layoutreturn without knowing that all I/O to the DS is
>> >> >> > finished. The fix is to remove the BUG_ON() now that the
>> >> >> > assumptions behind the test are obsolete.
>> >> >> >
>> >> >> Isn't MDS supposed to recall the layout if races are possible between
>> >> >> outstanding write-to-DS and write-through-MDS?
>> >> >
>> >> > Where do you read that in RFC5661?
>> >> >
>> >> That's my (maybe mis-)understanding of how server works... But looking
>> >> at rfc5661 section 18.44.3. layoutreturn implementation.
>> >> "
>> >> After this call,
>> >>    the client MUST NOT use the returned layout(s) and the associated
>> >>    storage protocol to access the file data.
>> >> "
>> >> And given commit 0a57cdac3f, client is using the layout even after
>> >> layoutreturn, which IMHO is a violation of rfc5661.
>> >
>> > No. It is using the layoutreturn to tell the MDS to fence off I/O to a
>> > data server that is not responding. It isn't attempting to use the
>> > layout after the layoutreturn: the whole point is that we are attempting
>> > write-through-MDS after the attempt to write through the DS timed out.
>> >
>> But it is RFC violation that there is in-flight DS IO when client
>> sends layoutreturn, right? Not just in-flight, client is well possible
>> to send IO to DS _after_ layoutreturn because some thread can hold
>> lseg reference and not yet send IO.
>
> Once the write has been sent, how do you know that it is no longer
> 'in-flight' unless the DS responds?
>
>> >> >> And it causes data corruption for blocklayout if client returns layout
>> >> >> while there is in-flight disk IO...
>> >> >
>> >> > Then it needs to turn off fast failover to write-through-MDS.
>> >> >
>> >> If you still consider it following rfc5661, I'd choose to disable
>> >> layoutreturn in before write-through-MDS for blocklayout, by adding
>> >> some flag like PNFS_NO_LAYOUTRET_ON_FALLTHRU similar to objects'
>> >> PNFS_LAYOUTRET_ON_SETATTR.
>> >
>> > I don't see how that will prevent corruption.
>> >
>> > In fact, IIRC, in NFSv4.2 Sorin's proposed changes specifically use the
>> > layoutreturn to communicate to the MDS that the DS is timing out via an
>> > error code (like the object layout has done all the time). How can you
>> > reconcile that change with a flag such as the one you propose?
>> I just intend to use the flag to disable layoutreturn in
>> pnfs_ld_write_done. block extents are data access permissions per
>> rfc5663. When we don't layoutreturn in pnfs_ld_write_done(), block
>> layout works correctly because server can decide if there is data
>> access race and if there is, MDS can recall the layout from client
>> before applying the MDS writes.
>>
>> Sorin's proposed error code is just a client indication to server that
>> there is disk access error. It is not intended to solve the data race
>> between write-through-MDS and write-through-DS.
>
> Then how do you solve that race on a block device?
As mentioned above, block extents are permissions per RFC5663. So if
MDS needs to access the disk, it needs the permission as well. So if
there is data access race, MDS must recall the layout from client
before processing the MDS writes. We've been dealing with the problem
for years in MPFS and it works perfectly to rely on MDS's decisions.

Thanks,
Tao
