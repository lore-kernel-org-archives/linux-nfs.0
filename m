Return-Path: SteveD@redhat.com
Message-ID: <5463C3F8.50004@RedHat.com>
Date: Wed, 12 Nov 2014 15:32:56 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>	<5462608B.1090607@RedHat.com>	<CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>	<54635BB5.1020702@RedHat.com>	<CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>	<5463787A.7080404@RedHat.com>	<CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>	<43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>	<5463A282.8060803@RedHat.com> <CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com> <5463C066.8030205@Netapp.com>
In-Reply-To: <5463C066.8030205@Netapp.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 11/12/2014 03:17 PM, Anna Schumaker wrote:
> On 11/12/2014 01:41 PM, Trond Myklebust wrote:
>> On Wed, Nov 12, 2014 at 1:10 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>> On 11/12/2014 10:37 AM, Chuck Lever wrote:
>>>>>> But I do see your point of not having to recompile mount
>>>>>>>> when we want to change the default minor release so
>>>>>>>> how that default is set is the question... Maybe
>>>>>>>> an environment variable??
>>>>>> That's still something that requires a user or sysadmin action, and it
>>>>>> wouldn't really play well with autofs and its ilk. As Marie Antoinette
>>>>>> would say: "Let them edit /etc/nfsmount.conf”
>>>> Fwiw: I thought this was the whole point of nfsmount.conf.
>>>> We should be able to rev nfs-utils while preserving the
>>>> administrator’s locally chosen default settings.
>>>>
>>>> +1 for using /etc/nfsmount.conf for this.
>>>>
>>> The reason the files exists is when we move the default
>>> version from v3 to v4 there would be away move the
>>> default back to v3 for legacy servers. Way
>>> way to move back from the future, if you will ;-)
>>> I never thought we would used it to go forward,
>>> just back...
>>>
>>> The problem with setting defaults in nfsmount.conf
>>> its not scalable especially in very large
>>> installations. I get it that distros can set
>>> it during installation, but that becomes error prone
>>> when different nfs-utils are used with different
>>> kernels. I think we should be more dynamic
>>>
>>> I think we barrow a paradigm from the server. On
>>> server the supported protocols are in /proc/fs/nfsd/verions
>>> that rpc.nfsd reads. We should do the same thing on the
>>> client.
>>>
>>> The kernel will tell mount.nfs where to start the negotiation.
>>>
>>> This will stop mount.nfs for needing to be compiled
>>> on minor version updates, plus it solves the problem
>>> of different kernels having different protocols enabled.
>>>
>>> I think this approach much more dynamic and it
>>> seems to work on the server side...
>>>
>> The NFS client modules are loaded on demand. The kernel will therefore
>> not actually know the capabilities until we attempt the mount.
>>
>>
> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
Maybe come up with some global bit field could be used?
Each bit signifies a minor version is enabled...

steved.
