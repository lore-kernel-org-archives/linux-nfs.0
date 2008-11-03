From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]:
Date: Mon, 03 Nov 2008 08:51:18 -0500
Message-ID: <490F01D6.3050204@RedHat.com>
References: <4902068D.2030201@RedHat.com> <20081031203903.GD8955@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45505 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754121AbYKCNxL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2008 08:53:11 -0500
In-Reply-To: <20081031203903.GD8955@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Oct 24, 2008 at 01:31:57PM -0400, Steve Dickson wrote:
>> [As requested, here is the debugging portion broken out of
>> the 6th patch in the "Dynamic Pseudo Root" patch series.]
>>
>> Added dprintk to the top and bottom of both expkey_parse() and
>> svc_export_parse(). The top dprintks shows what rpc.mountd gave
>> to the routines to parse. These match up well with the current
>> debugging statements in the rpc.mount routines nfsd_export()
>> and nfsd_fh(). 
>>
>> The bottom two dprintks show when either routine error out. This
>> was very useful in debugging why exports failed or hang.
> 
> 
> Did you try experiment with strace very much before trying this?
> Something like
> 
> 	strace -e read,write -s 1000 -p `pidof rpc.gssd`
> 
> will show the contents of the upcalls and downcalls and any returned
> error, so I'm not convinced that dprintk's of the upcall/downcall data
> are necessary.
> 
No, I have not, but it does look interesting and I'll give it try. 

But I also think its important to have one united debugging interface
that gives meaningful information when its turned on. 

For example, today you turn on export debugging with
    rpcdebug -m nfsd -s export 

you get a couple of "found this", "path is that" message that are 
basically meaningless and you have no idea where they are coming from.

When you turn on the cache debugging via:
    rpcdebug -m nfsd -s cache

you get absolutely nothing, since there is exactly one dprintk() in all
that code that I could never get to pop... 

So with my proposed dprinks it makes those commands much more meaningful and
useful by adding straightforward debugging strings that identify where they
are in the kernel. They also tie in nicely with the syslog entries that currently 
come out of the mountd debugging. Also they are not in a high traffic area. Meaning
they only pop when during exports and mounts, unlike an I/O path...

Maybe I'm don't understand the current debugging philosophy, but if a couple
non-intrusive dprintk make the debugging commands a bit more useful, why
isn't that a good thing?

steved.



