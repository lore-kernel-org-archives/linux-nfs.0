Return-Path: chuck.lever@oracle.com
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: mount default minor version behavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5463A282.8060803@RedHat.com>
Date: Thu, 13 Nov 2014 09:07:44 -0600
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D360B036-8F31-4287-BEA2-DDF72C64976A@oracle.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <5462608B.1090607@RedHat.com> <CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com> <54635BB5.1020702@RedHat.com> <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com> <5463787A.7080404@RedHat.com> <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com> <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com> <5463A282.8060803@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2014, at 12:10 PM, Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 11/12/2014 10:37 AM, Chuck Lever wrote:
>>>> But I do see your point of not having to recompile mount
>>>>>> when we want to change the default minor release so
>>>>>> how that default is set is the question... Maybe
>>>>>> an environment variable??
>>>>=20
>>>> That's still something that requires a user or sysadmin action, and =
it
>>>> wouldn't really play well with autofs and its ilk. As Marie =
Antoinette
>>>> would say: "Let them edit /etc/nfsmount.conf=94
>> Fwiw: I thought this was the whole point of nfsmount.conf.
>> We should be able to rev nfs-utils while preserving the
>> administrator=92s locally chosen default settings.
>>=20
>> +1 for using /etc/nfsmount.conf for this.
>>=20
> The reason the files exists is when we move the default
> version from v3 to v4 there would be away move the=20
> default back to v3 for legacy servers. Way=20
> way to move back from the future, if you will ;-)
> I never thought we would used it to go forward,
> just back...=20
>=20
> The problem with setting defaults in nfsmount.conf
> its not scalable especially in very large=20
> installations.

I=92m not sure what that means.

There are three sections of the configuration file: one
is for global behavior, right? What makes adding a
DefaultMinorVers here a problem?

If there is a scalability problem, shouldn=92t we try to
address that?


> I get it that distros can set
> it during installation, but that becomes error prone
> when different nfs-utils are used with different=20
> kernels. I think we should be more dynamic=20
>=20
> I think we barrow a paradigm from the server. On
> server the supported protocols are in /proc/fs/nfsd/verions
> that rpc.nfsd reads. We should do the same thing on the
> client.=20
>=20
> The kernel will tell mount.nfs where to start the negotiation.=20
>=20
> This will stop mount.nfs for needing to be compiled=20
> on minor version updates, plus it solves the problem
> of different kernels having different protocols enabled.
>=20
> I think this approach much more dynamic and it
> seems to work on the server side...=20
>=20
> steved.
>=20
>=20

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
