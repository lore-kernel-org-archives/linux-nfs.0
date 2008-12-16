From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NLM] 2.6.27 broken
Date: Tue, 16 Dec 2008 12:39:23 -0500
Message-ID: <20081216173923.GE16388@fieldses.org>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Miklos Szeredi <mszeredi@suse.cz>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757396AbYLPRjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 12:39:25 -0500
In-Reply-To: <20081128112447.GA25340@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 28, 2008 at 12:24:47PM +0100, Frank van Maarseveen wrote:
> On Thu, Nov 20, 2008 at 05:27:31PM -0500, J. Bruce Fields wrote:
> > On Sat, Nov 15, 2008 at 02:28:31PM +0100, Frank van Maarseveen wrote:
> > > Try running multiple instances of attached program on 1 NFS client
> > > against a 2.6.27(.5) NFSv3 server:
> > > 
> > > 	gcc -Wall -Wstrict-prototypes -o lck lck.c
> > > 	for i in `seq 30`
> > > 	do
> > > 		lck &
> > > 	done
> > 
> > Or reproduceable using the "flock" utility with:
> > 
> > 	for i in `seq 30`
> > 	do
> > 		flock /mnt/foo sleep 10

(Sorry, note there should be an ampersand at the end there....)

> > 	done
> > 
> > Hm.  What's the last known good server version?
> 
> 2.6.24.4

More precisely, it looks like this started with

	bde74e4bc64415b142e "locks: add special return value for
		asynchronous locks"

But I haven't had the chance to look any harder yet.  Miklos?  Is this
easy for you to reproduce?

--b.
