Return-Path: SteveD@redhat.com
Message-ID: <5463787A.7080404@RedHat.com>
Date: Wed, 12 Nov 2014 10:10:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>	<5462608B.1090607@RedHat.com>	<CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>	<54635BB5.1020702@RedHat.com> <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>
In-Reply-To: <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2014 09:31 AM, Trond Myklebust wrote:
>> My point is I don't think we need another variable, say
>> > DefaultMinVers, that defines the minor version of v4. I'm
>> > thinking that's its overkill and adds unnecessary complexity.
>> >
> I never said we do.
Ok... I misunderstood... 

> 
> I think we're in agreement mostly; the only point where I see
> disagreement is when Defaultvers is unset.
> My position is that in that situation, we don't know what starting
> point to use for minor version negotiation, and so we should just
> default to minor version 0: if the sysadmin want a different default,
> then the answer is to set Defaultvers...
Gotta... and there is a disagreement... I saying we make the
default the highest supported minor version. With the 
Linux client and server that's v4.2. So when no option is
given and Defaultvers is not set, try 4.2, then 4.1 and 
then 4.0 and finally v3.

But I do see your point of not having to recompile mount
when we want to change the default minor release so
how that default is set is the question... Maybe 
an environment variable?? 

One down side of being the aggressive with minor version
negotiation is legacy servers (aka AIX). Today we 
don't negotiate well with those types of servers... 
Its not our fault, but is a problem... 

steved. 
