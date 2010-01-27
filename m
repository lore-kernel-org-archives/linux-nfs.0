Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:41057 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab0A0TZl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 14:25:41 -0500
Received: by ewy19 with SMTP id 19so814364ewy.21
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jan 2010 11:25:40 -0800 (PST)
In-Reply-To: <1264619372.3788.96.camel@localhost>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com>
	 <d7f0b3a81001241609v35e54740yea3fa1a251b4f953@mail.gmail.com>
	 <0BA6F612-CE3A-47E9-B436-57E48506D769@oracle.com>
	 <d7f0b3a81001251102p5e631706jfd9f147a00487061@mail.gmail.com>
	 <641EC97D-2252-41FB-AEE8-0F1B77B5EA65@oracle.com>
	 <20100126232148.GA806@fieldses.org> <4B608492.2020702@oracle.com>
	 <1264617603.3788.77.camel@localhost>
	 <d7f0b3a81001271047l72adcc14ycf24cceb64a50644@mail.gmail.com>
	 <1264619372.3788.96.camel@localhost>
Date: Wed, 27 Jan 2010 20:25:39 +0100
Message-ID: <d7f0b3a81001271125t6a4bd395mc77d04ef663094da@mail.gmail.com>
Subject: Re: nfs client performance while server is down
From: Whoop Whouzer <tiredandnumb@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Muntz, Daniel" <Dan.Muntz@netapp.com>,
        Peter Chacko <peterchacko35@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am not stating this is an NFS problem at all. I am not asking anybody to fix
anything.
I asked if this issue was by design. I was told it wasn't (as nfs is stateless).
So, therefore I considered it as a bug (which I don't believe to
reside in either nfs or nautilus). I am just trying to figure out
where the problem lies.

I am not talking about implementing "disconnected NFS" mode,
synchronisation or anything like that. There is not something missing,
there is something not working properly, somewhere, and I'm trying to
find out where..

On Wed, Jan 27, 2010 at 8:09 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> So? I don't see why that would be an NFS problem.
>
> As far as I can see from this thread, you are basically asking us to fix
> these broken applications by implementing a "disconnected NFS" mode.
> While that may indeed be a cool thing to support, I haven't seen anybody
> so far stepping up and saying that they have the time and resources to
> work on it. Are you volunteering?
>
> Trond
>
> On Wed, 2010-01-27 at 19:47 +0100, Whoop Whouzer wrote:
>> ok, but it's not just GNOME/nautilus behaviour. For one, I am
>> experiencing problems with just about all applications that require
>> (local) disk access. Furthermore, problems have also been reported
>> with xfce/thunar and also with KDE.
>>
>> A bug for this issue has just been created for xfce/thunar:
>> http://bugzilla.xfce.org/show_bug.cgi?id=6185
>>
>> On Wed, Jan 27, 2010 at 7:40 PM, Trond Myklebust
>> <trond.myklebust@fys.uio.no> wrote:
>> > On Wed, 2010-01-27 at 13:23 -0500, Chuck Lever wrote:
>> >> On 01/26/2010 06:21 PM, J. Bruce Fields wrote:
>> >> > I wonder if nautilus (or some library it uses) likes to regularly
>> >> > "statfs" all the filesystems it knows about?
>> >>
>> >> The NFS client seems to like to send these periodically, but I've never
>> >> looked into why.  It's probably triggered by some cache timeout, and
>> >> gathers recent server file system information.
>> >
>> > No. It is entirely application driven. Furthermore, most of the statfs
>> > data is uncached, since it should not be performance critical in any
>> > sane application environment.
>> >
>> > IOW: I agree with Bruce that this is most likely GNOME or nautilus
>> > triggering statfs calls. Indeed, when I do actually open a window on
>> > some directory it also appears to display the free space.
>> >
>> > Trond
>> >
>> >
>> >
>
>
>
>
