Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:54719 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773Ab1LIDDD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 22:03:03 -0500
Date: Thu, 8 Dec 2011 21:53:20 -0500 (EST)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Sorin Faibish <sfaibish@emc.com>
Cc: honey@citi.umich.edu, linux-nfs@vger.kernel.org, nfsv4@ietf.org
Message-ID: <813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <op.v565vhhjrwwil4@sfaibish1.corp.emc.com>
Subject: Re: Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the slides, Sorin.

Just fyi, it was correct to not mention a FreeBSD client, since the
4.1 client code hasn't made it into any release yet. It is available
as a patch against the FreeBSD9.0 kernel, in case anyone is interested:
   http://people.freebsd.org/~rmacklem/nfsv4.1-client/nfsv41.patch

I am just starting to work on the logistics of getting this into the
FreeBSD source tree, so it may be in a FreeBSD9.n release, where n > 0.

Also, the above does not include any pNFS support. I am about ready to
start coding pNFS client stuff, which brings me to...
- It will be difficult for me to make much progress without any
  pNFS servers to test against. (The only NFSv4.1 server I have to
  test against is Fedora15 and I don't think it knows how to do pNFS?
  If there is a way to make Fedora15/16 (or any other freebie Linux
  distro) do pNFS, please let me know.

If others have suggestions on how I might gain access to pNFS servers
for testing, I would appreciate hearing. (However, I am not funded to
do any of this, so the suggestions can't include my spending $$$. I can
make it to a Bakeathon when it happens to be close to where I am, so I
can show up "on the cheap", like I did last June in Ann Arbor.)

rick

----- Original Message -----
> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish <sfaibish@emc.com>
> wrote:
> 
> > Attached please find the slides that we presented yesterday at
> > USENIX
> > LISA 11
> > conference in Boston. We would like to get more detailed input on
> > other
> > OS
> > that will support pNFS server/client (this is for Rick as well) that
> > were
> > not mentioned in this slide set.
> >
> > /Sorin
> >
> 
> 
> 
> --
> Best Regards
> Sorin Faibish
> Corporate Distinguished Engineer
> Unified Storage Division
> 
> EMC²
> where information lives
> 
> Phone: 508-435-1000 x 48545
> Cellphone: 617-510-0422
> Email : sfaibish@emc.com
