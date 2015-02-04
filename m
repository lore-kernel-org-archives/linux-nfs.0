Return-Path: linux-kernel-owner@vger.kernel.org
MIME-Version: 1.0
In-Reply-To: <20150204225230.2cc2749d@uranus>
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
	<20150204180833.4d4a22cf@neptune.home>
	<CAHQdGtT8OKR2hbZzpTOAYbtW1V7J0cSctxVfYq8QqobLcvGyhQ@mail.gmail.com>
	<20150204225230.2cc2749d@uranus>
Date: Wed, 4 Feb 2015 17:29:53 -0500
Message-ID: <CAHQdGtRB_edmLuxfxgVJRZ7yNB29Hq8arjmRXYzDoYF3tfQAyQ@mail.gmail.com>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during
 namespace cleanup
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 4, 2015 at 4:52 PM, Bruno Prémont <bonbons@linux-vserver.org> wrote:
> On Wed, 4 Feb 2015 14:06:48 Trond Myklebust wrote:
>> On Wed, Feb 4, 2015 at 12:08 PM, Bruno Prémont wrote:
>> > On Fri, 30 January 2015 Trond Myklebust wrote:
>> > > On Sun, 2015-01-25 at 16:55 -0500, Trond Myklebust wrote:
>> > > > On Sun, Jan 25, 2015 at 4:06 PM, Bruno Prémont wrote:
>> > > > > On a system running home-brown container (mntns, utsns,
>> > > > > pidns, netns) with NFS mount-point bind-mounted into the
>> > > > > container I hit the following trace if nfs filesystem is
>> > > > > first umount()ed in init ns and then later umounted from
>> > > > > container when the container exists.
>> > > > >
>> > > > > <snip trace>
>> > > >
>> > > > We should rather change rpcb_create() to pass the nodename from
>> > > > the parent. The point is that the rpc_clnt->cl_nodename is used
>> > > > in various different contexts (for instance in the AUTH_SYS
>> > > > credential) where it isn't always appropriate to have it set to
>> > > > an empty string.
>> > >
>> > > I was rather hoping that Bruno would fix up his patch and resend,
>> > > but since other reports of the same bug are now surfacing...
>> > > Please could you all check if something like the following patch
>> > > fixes it.
>> >
>> > This patch works for me, so
>> >   Tested-by: Bruno Prémont <bonbons@linux-vserver.org>
>> >
>> > Now I get just the following complaint in dmesg on shutdown:
>> >   [ 1940.173201] lockd: cannot unmonitor nfs.home
>> >                                          ^^^^^^^^  name of NFS
>> > server
>> >
>> > This complaint did not happen with my "empty string" name
>> > patch.
>>
>> Are there any clues from rpc.statd in your syslog that might help to
>> explain the error?
>
> I would say there is no more running rpc.statd at that time.
>
> My shutdown process looks about as follows (it's not necessarily the
> optimal ordering):
>
> - umount nfs mountpoints from root mntns
> - stop nfsclient
> - stop rpc.statd
> - stop rpcbind
> - stop containers (with bind-mounted nfs mountpoints from root mntns
>     that get implicitly umounted on mntns release)
>

In that case, the above message can be taken as a likely good
indication that the kernel is working as expected. If there is no
rpc.statd to talk to, then the unmonitor RPC call is expected to fail.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
