Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <20141113195516.GA28845@fieldses.org>
References: <43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>
	<5463A282.8060803@RedHat.com>
	<CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>
	<5463C066.8030205@Netapp.com>
	<5463C3F8.50004@RedHat.com>
	<CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
	<5464F10D.3010402@RedHat.com>
	<CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
	<20141113190213.GA28516@fieldses.org>
	<CAHQdGtR-e2vqZKZa0yy8tcwShyqJ-m-pVNxSzej8WApbEfTtcg@mail.gmail.com>
	<20141113195516.GA28845@fieldses.org>
Date: Thu, 13 Nov 2014 15:22:20 -0500
Message-ID: <CAHQdGtSUU3WkQ__VnuFpTY=BwS2in6Nk_3f+ycnsZVtXq0TTrQ@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 2:55 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Nov 13, 2014 at 02:26:20PM -0500, Trond Myklebust wrote:
>> On Thu, Nov 13, 2014 at 2:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Thu, Nov 13, 2014 at 01:52:09PM -0500, Trond Myklebust wrote:
>> >> On Thu, Nov 13, 2014 at 12:57 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> >> > On 11/12/2014 05:42 PM, Trond Myklebust wrote:
>> >> >>>> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
>> >> >>> > Maybe come up with some global bit field could be used?
>> >> >>> > Each bit signifies a minor version is enabled...
>> >> >>> >
>> >> >> No. This means that mount.nfs now suddenly needs to know the names of
>> >> >> the NFS modules and how to load them before it calls mount() just so
>> >> >> that it knows which parameters to try. This is a rathole we don't want
>> >> >> to explore...
>> >> > I don't think mount.nfs needs to know any names... Just
>> >> > a file /proc/fs/nfs/mount that tells mount.nfs where
>> >> > to start the negotiation....
>> >> >
>> >>
>> >> The kernel does not have that information until the NFSv4 module is loaded.
>> >
>> > I still don't get it.  All it needs to know is an upper bound--that
>> > could be a single compile-time constant.  Is there any reason not to
>> > build that number into the main nfs module?
>> >
>>
>> Firstly, the main nfs module isn't preloaded either.
>
> That doesn't sound like a big deal.
>
>> Secondly, that's a layering violation. The main nfs module has no
>> business knowing anything about the sub-modules other than how to load
>> them when needed.  If I want to recompile my NFSv4 module to add
>> NFSv4.2 support, then I shouldn't have to recompile the entire
>> contents of my nfs directory.
>
> You don't have to, you just have to mount with -oversion=4.2  in that
> case.
>
> The compile-time constant here is just a default starting point for
> negotation.
>
> As long as there's no stable kernel API, and end users don't routinely
> load modules from the future, the nfs module seems like a reasonable
> enough place to store the default minorversion.
>

It is reasonable if and only if your process can load modules and read
procfs, neither of which are guaranteed in all situations where we may
want to use mount.nfs.

IOW: no...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
