From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Fri, 19 Dec 2008 14:11:46 -0500
Message-ID: <1229713906.7789.159.camel@heimdal.trondhjem.org>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
	 <1229018528.6463.23.camel@heimdal.trondhjem.org>
	 <9ef864c50812111330v1c9dc200s49dacb5504bbfeca@mail.gmail.com>
	 <9ef864c50812190834p7a63d572s3bd99f964254cc@mail.gmail.com>
	 <1229710786.7789.138.camel@heimdal.trondhjem.org>
	 <9ef864c50812191036s35f30e5bia33b8024fec4d42e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Thomas Garner <thomas536@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52535 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126AbYLSTLv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Dec 2008 14:11:51 -0500
In-Reply-To: <9ef864c50812191036s35f30e5bia33b8024fec4d42e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-12-19 at 13:36 -0500, Thomas Garner wrote:
> > As far as I can see from your tcpdump, there is no NFS network activity
> > at all, so the recovery thread is obviously hung. What does
> > 'echo t > /proc/sysrq-trigger' tell you that the thread is doing?
> 
> Here you go:
> 
> http://s120158928.onlinehome.us/messages_sysrq.7.gz

OK. It looks as if that thread is hanging waiting for some other thread
to release the sequence lock. However, I couldn't see anything other
than a firefox session actually in the NFS code in your sysrq trace.
That thread couldn't holding the sequence lock, since it was actually
doing those WRITE calls that figure in the above messages.

The syslog trace seems incomplete, though. Can you see more information
if you use

	dmesg -s 90000

Trond

