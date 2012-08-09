Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:51137 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754935Ab2HIRGr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 13:06:47 -0400
Received: by ggdk6 with SMTP id k6so682568ggd.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 10:06:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344529783.25447.32.camel@lade.trondhjem.org>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
 <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
 <1344522979.23523.2.camel@lade.trondhjem.org> <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>
 <1344526780.25447.6.camel@lade.trondhjem.org> <CA+a=Yy5zrdt6xAHFhXk9KypjGRvy2CbWC2DcNnudPDQ4ni=urA@mail.gmail.com>
 <1344529783.25447.32.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 10 Aug 2012 01:06:25 +0800
Message-ID: <CA+a=Yy7j17VorVy7dY5TxG=3CrVnR3pj8XOMcEUBek0Xe2Cdqw@mail.gmail.com>
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
RFC5663 provides a way.
"
"blh_maximum_io_time" is the maximum
   time it can take for a client I/O to the storage system to either
   complete or fail
"
It is not perfect solution but still serves as a best effort. It
solves the in-flight IO question for current writing thread.

For in-flight IO from other concurrent threads, lseg reference is the
source that we can rely on. And I think that the BUG_ON can be
triggered much easily because of concurrent writing threads and one of
them fails DS writes.

-- 
Thanks,
Tao
