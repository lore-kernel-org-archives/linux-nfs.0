Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <5463787A.7080404@RedHat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
	<5462608B.1090607@RedHat.com>
	<CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>
	<54635BB5.1020702@RedHat.com>
	<CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>
	<5463787A.7080404@RedHat.com>
Date: Wed, 12 Nov 2014 10:28:53 -0500
Message-ID: <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 10:10 AM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 11/12/2014 09:31 AM, Trond Myklebust wrote:
>>> My point is I don't think we need another variable, say
>>> > DefaultMinVers, that defines the minor version of v4. I'm
>>> > thinking that's its overkill and adds unnecessary complexity.
>>> >
>> I never said we do.
> Ok... I misunderstood...
>
>>
>> I think we're in agreement mostly; the only point where I see
>> disagreement is when Defaultvers is unset.
>> My position is that in that situation, we don't know what starting
>> point to use for minor version negotiation, and so we should just
>> default to minor version 0: if the sysadmin want a different default,
>> then the answer is to set Defaultvers...
> Gotta... and there is a disagreement... I saying we make the
> default the highest supported minor version. With the
> Linux client and server that's v4.2. So when no option is
> given and Defaultvers is not set, try 4.2, then 4.1 and
> then 4.0 and finally v3.

Only for Linux 3.11 and newer, and only if they enable CONFIG_NFS_V4_2
/ CONFIG_NFSD_V4_SECURITY_LABEL.

Unless we want to have different defaults for older kernels, this sort
of implies that we're moving in the direction of coupling the
nfs-utils releases more tightly to the kernel version. I'm neutral to
that, but I do want to call it out.

> But I do see your point of not having to recompile mount
> when we want to change the default minor release so
> how that default is set is the question... Maybe
> an environment variable??

That's still something that requires a user or sysadmin action, and it
wouldn't really play well with autofs and its ilk. As Marie Antoinette
would say: "Let them edit /etc/nfsmount.conf"

> One down side of being the aggressive with minor version
> negotiation is legacy servers (aka AIX). Today we
> don't negotiate well with those types of servers...
> Its not our fault, but is a problem...

Is this because they don't implement that part of RFC3530?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
