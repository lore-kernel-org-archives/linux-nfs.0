From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 18:01:54 +0200
Message-ID: <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
	 <1251115893.6325.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:53695 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbZHYQB5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 12:01:57 -0400
Received: by fxm17 with SMTP id 17so2242907fxm.37
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 09:01:57 -0700 (PDT)
In-Reply-To: <1251115893.6325.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Trond for the input! I've got just one more puzzle (s.below)

On Mon, Aug 24, 2009 at 2:11 PM, Trond Myklebust wrote:
>
> On Mon, 2009-08-24 at 12:32 +0200, Stefan Egli wrote:
>
> > 2) I'm still not sure I understand that patch correctly though
> > =A0 =A0(37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e5): Would the tivoli =
restore
> > =A0 =A0be able to mess with mtimes and *therefore* cause the 4-5 ho=
ur cache
> > =A0 =A0inconsistency I'm seeing? If yes, would the patch then magic=
ally fix this?
>
> If tivoli is messing with the mtime, then it _might_ cause the
> condition, in a restore situation by changing the directory contents =
but
> not the mtime (which is what tells the NFS client and applications th=
at
> the directory contents have changed).
> By looking at the ctime too, the client can always tell that somethin=
g
> has changed, and thus clear its cache.

I suspect, the problem I'm seeing could be similar to this one:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/269172

What puzzles me with that 269172 bug is that it requires that you
first do a 'ls' on machine A - then do that script mentioned in the
bug on machine B -
and then do another 'ls' on machine A. This looks like with the first '=
ls'
machine A fills its attribute-cache - which then later on becomes out-o=
f-sync
with what the NFS server says.

In my situation though, I'm not doing any ls in the subdirectories affe=
cted -
which would mean it's not 100% explainable with the above bug... bugger=
=2E..

or is it ?

>
> > =A0 =A0(not restore) could cause completely unrelated files (which =
we update every
> > =A0 =A05 minutes using some simple raw shell scripts) to remain out=
-of-sync
> > =A0 =A0with other NFS clients - that is, client A changes the conte=
nt every 5 min
> > =A0 =A0but client B and C see it only after 1-2 hours. Seems somewh=
at new and
> > =A0 =A0unrelated to the restore case of above - as restore does cha=
nge directory
> > =A0 =A0content (and that's where the problem lies) but backup merel=
y changes
> > =A0 =A0the file's mtime probably (but not even sure it does that - =
maybe leaves it
> > =A0 =A0unchanged)
>
> > 3) The other part of my issue which I still don't understand is, wh=
y a backup
> I've no idea why the other clients aren't seeing a change in this cas=
e.
> I certainly cannot reproduce this with my own setup.
>
> With the default acdirmin/max settings, the clients should not be
> caching the mtime for longer than 1 minute. While they might be blind=
 to
> the directory changes during that time, they should at least see it
> after the minute expires.

=46orget this issue - I found the problem - not related to NFS


Cheers,
Stefan
