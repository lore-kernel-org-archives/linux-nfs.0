Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44766 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030692Ab2HHTpb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 15:45:31 -0400
Received: by wibhm11 with SMTP id hm11so4207523wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 12:45:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344450818.8925.17.camel@lade.trondhjem.org>
References: <CAGue13pvN_-wBqQVoNdkLO+pexF1hrs+d3exPCCSzOO8ZD4WRw@mail.gmail.com>
	<1344447279.8925.5.camel@lade.trondhjem.org>
	<CADnza47D=j2jh+AHR9vs36HqpCmcES02v4FkDNufepdS3c-CDQ@mail.gmail.com>
	<1344449028.8925.12.camel@lade.trondhjem.org>
	<CADnza471-DQ2C6U3pxw=Hj+WBBOFAJphC-gWGE7hQ=k3E3bn0Q@mail.gmail.com>
	<1344450818.8925.17.camel@lade.trondhjem.org>
Date: Wed, 8 Aug 2012 15:45:30 -0400
Message-ID: <CADnza45v28X0PohO66FXfxTJtUmRn+a7AkrrsSD5gPG3wUAi0Q@mail.gmail.com>
Subject: Re: client kernel panic on server restart
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 8, 2012 at 2:33 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-08-08 at 14:15 -0400, Fred Isaman wrote:
>> On Wed, Aug 8, 2012 at 2:03 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Wed, 2012-08-08 at 13:51 -0400, Fred Isaman wrote:
>> >> On Wed, Aug 8, 2012 at 1:34 PM, Myklebust, Trond
>> >> <Trond.Myklebust@netapp.com> wrote:
>> >> > On Wed, 2012-08-08 at 18:48 +0200, Tigran Mkrtchyan wrote:
>> >> >> Hi,
>> >> >>
>> >> >> It's quite some time without kernel panic reports from me ....
>> >> >>
>> >> >> Observer on MDS and DS shutdown during IO.
>> >> >>
>> >> >> This is with  3.5.0-2.fc17.x86_64 kernel. Line in code:
>> >> >>
>> >> >> nfs4proc.c:6252 :   BUG_ON(!list_empty(&lo->plh_segs));
>> >> >>
>> >> >
>> >> > If the server doesn't return a stateid, then that is supposed to
>> >> > indicate that it thinks that it doesn't hold any more layout segments
>> >> > for this file.
>> >> > To me, that indicates that we should be calling
>> >> > mark_matching_lsegs_invalid() rather than Oopsing.
>> >> >
>> >> > Any dissenting voices from the pNFS crowd?
>> >> >
>> >>
>> >> But this implies that the client thinks it has a layout which the
>> >> server does not believe it has, which seems to me to imply an earlier
>> >> bug.  If you change to mark_matching_lsegs_invalid, I would suggest
>> >> keeping a WARN_ON.
>> >
>> > We could possibly add a printk, but I don't see what value a WARN_ON
>> > would have here: how is a stack dump going to be useful in debugging
>> > this issue?
>> >
>> > Also, don't we sometimes expect this sort of thing to happen on
>> > occasion? What if our layoutreturn ends up racing with the layout recall
>> > following a DS shutdown?
>> >
>>
>> Actually, I forgot about the whole LAYUTRETURN as fencing possibility.
>>  In that case, you can pretty easily hit the BUG_ON.  Though I claim
>> that, while calling mark_matching_lsegs_invalid doesn't hurt, it
>> should be unnecessary.
>
> Right... So maybe just a dprintk() for debugging purposes?
>
> BTW: Why shouldn't we do the mark_matching_lsegs_invalid? If not, then
> we will need either to do an extra layoutreturn or fail a read/write
> attempt to the DS in order to figure out that the stateid is now
> invalid.
>


They should have already been marked as invalid, and are just waiting
on io to finish for release.

Fred
