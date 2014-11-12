Return-Path: chuck.lever@oracle.com
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: mount default minor version behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
Date: Wed, 12 Nov 2014 09:37:46 -0600
Cc: Steve Dickson <SteveD@redhat.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <5462608B.1090607@RedHat.com> <CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com> <54635BB5.1020702@RedHat.com> <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com> <5463787A.7080404@RedHat.com> <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2014, at 9:28 AM, Trond Myklebust =
<trond.myklebust@primarydata.com> wrote:

> On Wed, Nov 12, 2014 at 10:10 AM, Steve Dickson <SteveD@redhat.com> =
wrote:
>>=20
>>=20
>> On 11/12/2014 09:31 AM, Trond Myklebust wrote:
>>>> My point is I don't think we need another variable, say
>>>>> DefaultMinVers, that defines the minor version of v4. I'm
>>>>> thinking that's its overkill and adds unnecessary complexity.
>>>>>=20
>>> I never said we do.
>> Ok... I misunderstood...
>>=20
>>>=20
>>> I think we're in agreement mostly; the only point where I see
>>> disagreement is when Defaultvers is unset.
>>> My position is that in that situation, we don't know what starting
>>> point to use for minor version negotiation, and so we should just
>>> default to minor version 0: if the sysadmin want a different =
default,
>>> then the answer is to set Defaultvers...
>> Gotta... and there is a disagreement... I saying we make the
>> default the highest supported minor version. With the
>> Linux client and server that's v4.2. So when no option is
>> given and Defaultvers is not set, try 4.2, then 4.1 and
>> then 4.0 and finally v3.
>=20
> Only for Linux 3.11 and newer, and only if they enable CONFIG_NFS_V4_2
> / CONFIG_NFSD_V4_SECURITY_LABEL.
>=20
> Unless we want to have different defaults for older kernels, this sort
> of implies that we're moving in the direction of coupling the
> nfs-utils releases more tightly to the kernel version. I'm neutral to
> that, but I do want to call it out.
>=20
>> But I do see your point of not having to recompile mount
>> when we want to change the default minor release so
>> how that default is set is the question... Maybe
>> an environment variable??
>=20
> That's still something that requires a user or sysadmin action, and it
> wouldn't really play well with autofs and its ilk. As Marie Antoinette
> would say: "Let them edit /etc/nfsmount.conf=94

Fwiw: I thought this was the whole point of nfsmount.conf.
We should be able to rev nfs-utils while preserving the
administrator=92s locally chosen default settings.

+1 for using /etc/nfsmount.conf for this.

>=20
>> One down side of being the aggressive with minor version
>> negotiation is legacy servers (aka AIX). Today we
>> don't negotiate well with those types of servers...
>> Its not our fault, but is a problem...
>=20
> Is this because they don't implement that part of RFC3530?
>=20
> --=20
> Trond Myklebust
>=20
> Linux NFS client maintainer, PrimaryData
>=20
> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
