Return-Path: SteveD@redhat.com
Message-ID: <5465152D.30208@RedHat.com>
Date: Thu, 13 Nov 2014 15:31:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <5462608B.1090607@RedHat.com> <CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com> <54635BB5.1020702@RedHat.com> <CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com> <5463787A.7080404@RedHat.com> <CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com> <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com> <5463A282.8060803@RedHat.com> <D360B036-8F31-4287-BEA2-DDF72C64976A@oracle.com>
In-Reply-To: <D360B036-8F31-4287-BEA2-DDF72C64976A@oracle.com>
Content-Type: text/plain; charset=windows-1252
List-ID: <linux-nfs.vger.kernel.org>

On 11/13/2014 10:07 AM, Chuck Lever wrote:
>> The problem with setting defaults in nfsmount.conf
>> > its not scalable especially in very large 
>> > installations.
> I’m not sure what that means.
> 
> There are three sections of the configuration file: one
> is for global behavior, right? What makes adding a
> DefaultMinorVers here a problem?
Its not so much its difficult to do, its difficult to
manage especially when it comes to changing something
in a vary large installation.
 
> 
> If there is a scalability problem, shouldn’t we try to
> address that?
I'm trying to avoid one... ;-)

I just think one should be able to install a new kernel 
that supports a new minor version and have mount.nfs be 
able to use the minor version w/out recompile or 
editing some config file.. 

steved.
