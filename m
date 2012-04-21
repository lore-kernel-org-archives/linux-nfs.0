Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:50370 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079Ab2DVAFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Apr 2012 20:05:47 -0400
Message-ID: <1335052658.17583.4.camel@obed>
Subject: Re: NFSv4 ACLs
From: Andrew Bartlett <abartlet@samba.org>
To: steve <steve@steve-ss.com>
Cc: simo <idra@samba.org>, linux-nfs@vger.kernel.org,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        Jeremy Allison <jra@samba.org>, Ondrej Valousek <webserv@s3group.com>
Date: Sun, 22 Apr 2012 09:57:38 +1000
In-Reply-To: <4F929B50.1020407@steve-ss.com>
References: <4F913492.8000402@s3group.cz> <20120420185553.GB32622@samba2>
	 <20120420212627.GA710@fieldses.org> <20120420215945.GE32622@samba2>
	 <20120420220832.GA1914@fieldses.org>
	 <1334972084.2492.722.camel@pico.li.ssimo.org>
	 <4F929B50.1020407@steve-ss.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2012-04-21 at 13:34 +0200, steve wrote:
> On 21/04/12 03:34, simo wrote:
> > On Fri, 2012-04-20 at 18:08 -0400, J. Bruce Fields wrote:
> >> On Fri, Apr 20, 2012 at 02:59:45PM -0700, Jeremy Allison wrote:
> >>> On Fri, Apr 20, 2012 at 05:26:27PM -0400, J. Bruce Fields wrote:
> >>>> On Fri, Apr 20, 2012 at 11:55:53AM -0700, Jeremy Allison wrote:
> >>>>> On Fri, Apr 20, 2012 at 12:04:02PM +0200, Ondrej Valousek wrote:
> >>>>>> Hi List,
> >>>>>>
> 
> >
> >> (By the way, is reexporting nfs with samba really going to work well
> >> anyway?)
> >
> > Not really, it is generally unsupported, except for read only shares. It
> > will work in most of the simple cases for writing .. until it breaks :)
> >
> 
> Hi
> That's worrying.
> 
> We been rw'ing nfs/samba for years.  Maybe we're the only ones. nfs3 for 
> our Linux clients and samba for the rest. Same shared data. Only Posix 
> acl's though. Maybe that's the simple bit?
> Cheers,
> Steve

Are Samba and NFSd running on the same server, exporting the same data?
That is what is expected to work.  See 'kernel oplocks' (the default of
which will change for 4.0) to allow NFS and Samba to break each other's
oplocks.

What Simo cautions about is where an NFS server (say a NAS server)
exports to some direct NFS clients, and then a 'proxy' Samba server is
an NFS client and a Samba server for Windows clients.  This 'proxy'
setup is considered dangerous. 

Andrew Bartlett

-- 
Andrew Bartlett                                http://samba.org/~abartlet/
Authentication Developer, Samba Team           http://samba.org

