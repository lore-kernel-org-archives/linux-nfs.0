From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Sun, 20 Jul 2008 21:28:48 -0400
Message-ID: <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com>
References: <18556.40594.897682.204554@notabene.brown>
	 <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	 <18559.53893.95829.499988@notabene.brown>
	 <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com>
	 <18562.57287.656749.540603@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:25296 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623AbYGUB2u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jul 2008 21:28:50 -0400
Received: by fg-out-1718.google.com with SMTP id 19so540809fgg.17
        for <linux-nfs@vger.kernel.org>; Sun, 20 Jul 2008 18:28:49 -0700 (PDT)
In-Reply-To: <18562.57287.656749.540603-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 20, 2008 at 2:48 AM, Neil Brown <neilb@suse.de> wrote:
> On Saturday July 19, chuck.lever@oracle.com wrote:
>> > Suppose we were to take this approach:
>> >
>> >   mount.nfs does DNS lookup and portmap look to find IP address and
>> >      port number.  However it *doesn't* send a 'clnt_ping' as
>> >      probe_port currently does.
>> >   The information it collects is explicitly given to the kernel with
>> >       mountproto= mountport= etc.
>> >   The kernel talks directly to mountd (given proto/addr/port) to get
>> >      the filehandle and so forth.  It doesn't talk to portmap at all
>> >      if it is given the required port numbers.
>> >
> ...
>> >
>> > Thoughts?
>>
>> Using a connected UDP socket for both the kernel's rpcbind and it's
>> mountd client could help in many cases, including, probably, the one
>> you mention below, without the need for changing the current
>> architecture.
>>
>> One thing about explicitly specifying mountport and mountproto during
>> a mount is that the umount.nfs command may have to include some logic
>> to throw those out and reprobe if those settings don't work at unmount
>> time.  These options were added to allow traversing a firewall using a
>> fixed port and protocol; overloading them for the case you describe
>> above may perhaps have some unpleasant consequences for the fixed
>> port/protocol case.
>>
>
> Yes....  umount wouldn't know the difference between:
>  - don't use portmap, it doesn't work.  Just use this port number.
> and
>  - I used portmap and got this port number, so maybe it will be
>    useful to you to.
>
> In the first case umount should only use the mountport given.  In the
> second case it arguably should not and should always talk to portmap
> to get he port number (as it could be much later and mountd may well
> be on a different port).
>
>
>> >> > If an NFS server is only listening on TCP for portmap (as apparently
>> >> > MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
>> >> > logic in case the initial choice of version/etc doesn't work, but it
>> >> > doesn't cope with mountd needing tcp.
>>
>> I think that is mostly because the text-based mount option rewriting
>> logic isn't robust yet.  I have several patches in the IPv6 series
>> that should address some of this.
>
> Any chance of pulling these out and sending them upstream now?  or is
> the IPv6 series very close to release?

IPv6 is actively being worked on.  I expect all these will be
available in the next 6 months.  However this specific set of patches
is dependent on some extensive changes (like, a complete
re-implementation of mount's portmap client).  Pulling them out now
would be a lot of work and I'm not sure it's worth the distraction to
the IPv6 effort, which essentially needed to be complete last month.

>> But many of Linux's NFS auxiliary services are UDP-only.  statd and
>> sm-notify, for instance, are UDP-only as far as I can tell.  And
>> recently the kernel's NLM service was changed to listen only on TCP if
>> clients are connecting to servers only via TCP -- and that breaks some
>> local Linux services that assume UDP will always be there (like
>> SM_MON).
>
> I'm not so much focussed on "make it work without UDP" as "avoid a
> regression".  The current code doesn't work in situations where the
> old code does work.  That is bad.

So, it is well known that there are some areas where text-based mounts
don't work as well as legacy mounts.  The problem is we don't have a
anything like a complete requirements specification for NFS mounting
(let alone a sophisticated or even simple regression/unit test suite
for mount), so it's really quite impossible to expect that a
completely new architecture will work out of the box.  We do know that
the existing legacy ABI is insufficient for many reasons.  I don't
think any one of us on this list has a complete enough history with
mount to know precisely which use cases are the ones we need to carry
forward to the text-based mount interface.

I've expected some problems in this area, and the only thing I can
hope for is that people will diligently report problems.  If you have
specific problems with the text-based implementation, I'd like to hear
about them so we can clear them up as quickly as possible.  I never
claimed that work is complete yet.

> I'd just like to get the regression fixed.

Me too.

Is it not sufficient to use connected UDP sockets in both user space
and the kernel, and fix the kernel to return EPROTONOTSUPP where
appropriate?

A healing balm for those who would like to use late model nfs-utils
releases but don't want the hassle of the remaining bugs in the
text-based mounts may be in order.  It would be easy to add a
configure switch to use only the legacy ABI interface for mount.nfs.

-- 
Chuck Lever
