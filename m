Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48512 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932162AbcEKOF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2016 10:05:27 -0400
Date: Wed, 11 May 2016 10:05:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Configuring NFSv4.0 Kerberos on a multi-homed Linux NFS server
Message-ID: <20160511140524.GA24648@fieldses.org>
References: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com>
 <8198666A-8963-42D2-9C4C-08374F0E8E5D@oracle.com>
 <20160506024401.GC5365@fieldses.org>
 <9E194D65-280F-4107-979C-FEFF2B83B211@oracle.com>
 <20160506161332.GA11400@fieldses.org>
 <A0A26870-27A4-48BE-ABA2-048A110F5272@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A0A26870-27A4-48BE-ABA2-048A110F5272@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 09, 2016 at 11:00:06AM -0400, Chuck Lever wrote:
> 
> > On May 6, 2016, at 12:13 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, May 06, 2016 at 09:23:40AM -0400, Chuck Lever wrote:
> >> 
> >>> On May 5, 2016, at 10:44 PM, Bruce Fields <bfields@fieldses.org> wrote:
> >>> 
> >>> On Thu, May 05, 2016 at 05:01:58PM -0400, Chuck Lever wrote:
> >>>> After some IRC discussion with Bruce, we think the answer
> >>>> is "this is not supported in the current Linux NFS server."
> >>>> 
> >>>> The server does not have a way to determine which service
> >>>> principal to use for NFSv4.0 callback operations. It picks
> >>>> (probably) the first nfs/ service principal in the server's
> >>>> keytab for all callback operations.
> >>>> 
> >>>> Thus if a Linux NFS server has a keytab, clients can mount
> >>>> it with NFSv4.0 (and any security flavor) only on the i/f
> >>>> whose hostname matches the name of the nfs/ service
> >>>> principal in that server's keytab.
> >>> 
> >>> One correction: the mount should still work correctly.  The server just
> >>> won't grant any delegations to the client.
> >> 
> >> Unfortunately this is not the case.
> > 
> > Ugh, OK, that's worse than I thought.  I guess you can work around it on
> > the server side with "echo 0 >/proc/sys/fs/leases-enable".
> 
> Google can find this e-mail thread, but would like me to
> open a bug report on bugzilla.linux-nfs.org as well, Bruce?

Up to you.  I'll confess to mostly ignoring upstream bugzilla until
it sends me email.

By the way, were you using gss-proxy?  (What distro?)  Did it take any
special configuration to get the basic protocol working with multiple
principals, beyond just creating the keytabs?

--b.
