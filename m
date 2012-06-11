Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab2FKOL5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jun 2012 10:11:57 -0400
Date: Mon, 11 Jun 2012 10:11:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: bfields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Platte <jplatte@naasa.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
Message-ID: <20120611101141.143fff3c@corrin.poochiereds.net>
In-Reply-To: <4FD5FB28.4050003@panasas.com>
References: <4FD47D4E.9070307@naasa.net>
	<1339340441.4751.1.camel@lade.trondhjem.org>
	<20120611121634.GB7654@fieldses.org>
	<20120611083932.24e27e39@corrin.poochiereds.net>
	<4FD5F35A.3000903@panasas.com>
	<20120611095132.045a8d09@corrin.poochiereds.net>
	<4FD5FB28.4050003@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Jun 2012 17:05:28 +0300
Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 06/11/2012 04:51 PM, Jeff Layton wrote:
> 
> > 
> > That was considered here, but the problem with the usermode helper is
> > that you can't pass anything back to the kernel but a simple status
> > code (and that's assuming that you wait for it to exit). In the near
> > future, we'll need to pass back more info to the kernel for this, so
> > the usermode helper callout wasn't suitable.
> > 
> 
> 
> I have answered that in my mail. Repeated here again. Well you made 
> a simple mistake. Because it is *easy* to pass back any number and
> size of information from user-mode.
> 
> You just setup a sysfs entry points where the answers are written
> back to. It's an easy trick to setup a thread safe, way with a
> cookie but 90% of the time you don't have to. Say you set up
> a structure of per-client (identified uniquely) then user mode
> answers back per client, concurrency will not do any harm, since
> you answer to the same question the same answer. ans so on. Each
> problem it's own.
> 
> If you want we can talk about this, it would be easy for me to setup
> a toll free conference number we can all use.

That helpful advice would have been welcome about 3-4 months ago when I
first proposed this in detail. At that point you're working with
multiple upcall/downcall mechanisms, which was something I was keen to
avoid.

I'm not opposed to moving in that direction, but it basically means
you're going to rip out everything I've got here so far and replace it.

If you're willing to do that work, I'll be happy to work with you on
it, but I don't have the time or inclination to do that on my own right
now.

-- 
Jeff Layton <jlayton@redhat.com>
