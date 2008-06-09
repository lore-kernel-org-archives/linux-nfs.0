From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with large number of clients and reads
Date: Mon, 9 Jun 2008 14:53:55 -0400
Message-ID: <20080609185355.GF28584@fieldses.org>
References: <1212519001.24900.14.camel@hololw58> <20080606160922.GG30863@fieldses.org> <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49346 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbYFISx5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 14:53:57 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C2977010155587-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 09, 2008 at 09:19:03AM -0500, Weathers, Norman R. wrote:
> >I'd've thought that suggests a leak of memory allocated by kmalloc().
> 
> >Does the size-4096 cache decrease eventually, or does it stay that
> >large until you reboot?
> 
> I would agree that it "looks" like a memory leak.  If I restart NFS,
> the size-4096 cache goes from 12 GB to under 50 MB,

And restarting nfsd is the only thing you've found that will do this?
(So decreasing the number of threads, or stopping all the client won't
do anything to the size-4096 number?)

> but then depending
> upon how hard the box is utilized, it starts to climb back up.

> I have
> seen it climb back up to 3 or 4 GB right after the restart, but that
> is much better because the regular disk cache will grow from the 2 GB
> that it was pressured into back to 5 or 8 GB, so all of the files have
> been reread into memory and things are progressing smoothly.  It is
> weird.  I really think that this has to do with a lot of connections
> happening at once, because I can run slabtop and see a node that is
> running full out, but only have a couple hundred megs of the size-4096
> slab being used, and then turn around and see another node that is
> pushing out 245 MB/s and all of the sudden using over 12 GB of the
> size-4096.  It is very odd...  If I lower the number of threads from a
> usable 64 to a low of 3 threads, I have less of a chance of the
> servers going haywire, to the point of being so loaded they may crash
> or you cannot contact them over the network (fortunately, I have
> serial on these boxes so that I can get on the nodes if they reach
> that point).  If I run 8 threads, and with enough clients, I can bring
> down one of these servers. size-4096 goes through the roof, and
> depending on the hour of the day, the server can either crash or
> becomes unresponsive.

These are doing only NFS v2 and v3?  (No v4?)

--b.
