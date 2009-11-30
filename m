From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Client cache updates missing? (2.6.31.5)
Date: Mon, 30 Nov 2009 13:53:02 -0500
Message-ID: <1259607182.3419.13.camel@localhost>
References: <4B122FB2.7040505@krogh.cc> <20091130182643.GB6348@fieldses.org>
	 <4B140F5F.6050107@krogh.cc>  <20091130184035.GD6348@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35298 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbZK3SxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 13:53:00 -0500
In-Reply-To: <20091130184035.GD6348@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-30 at 13:40 -0500, J. Bruce Fields wrote: 
> On Mon, Nov 30, 2009 at 07:30:55PM +0100, Jesper Krogh wrote:
> > J. Bruce Fields wrote:
> > >> Wether or not it has anything to do. The file has been written to the
> > >> NFS-server from another NFS-client. The server is running 2.6.31.5 and
> > >> the client that above was run on is 2.6.24-24 (Ubuntu Jaunty), the
> > >> client that wrote the file was running 2.6.29.1.
> > > 
> > > I this v3 or v4?  What's the exported filesystem?  (ext3?)
> > 
> > v3 and ext3
> > 
> > > It's probably a timestamp resolution problem; if the directory was
> > > modified twice in the same second, the later change won't change the
> > > timestamp, and so the client may assume its cache is still good.
> > 
> > That's not nice..  but given the situation is may quite well be the
> > problem.
> > 
> > > Recent clients try a little harder to work around this. 
> > 
> > How recent and how much harder?
> 
> There's the following.  Looks like it was first included in 2.6.30.  I
> thought I remembered one or two other related changes, but perhaps the
> others didn't make it in.

There are also a bunch of attribute revalidation changesets that went
into 2.6.28, and that improved the NFS client's ability to keep
attributes up to date.

  Trond

