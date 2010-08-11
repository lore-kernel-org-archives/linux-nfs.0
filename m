Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:32821 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755907Ab0HKXGL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Aug 2010 19:06:11 -0400
Date: Thu, 12 Aug 2010 09:06:02 +1000
From: Neil Brown <neilb@suse.de>
To: David Brodbeck <brodbd@u.washington.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100812090602.3a24c2bd@notabene>
In-Reply-To: <03068BD0-0613-469E-B918-07019EC54055@u.washington.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx>
	<20100803164318.GB13896@merit.edu>
	<20100803192216.GC31579@fieldses.org>
	<DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
	<20100803215704.GA15494@merit.edu>
	<1280873719.14520.17.camel@heimdal.trondhjem.org>
	<20100803222337.GA9752@fieldses.org>
	<1280874675.14520.23.camel@heimdal.trondhjem.org>
	<20100803224245.GB9752@fieldses.org>
	<1280887336.24669.23.camel@heimdal.trondhjem.org>
	<0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
	<C2AFF31B-A4A4-432C-A152-B28676B8C3A4@netapp.com>
	<03068BD0-0613-469E-B918-07019EC54055@u.washington.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 4 Aug 2010 14:32:06 -0700
David Brodbeck <brodbd@u.washington.edu> wrote:

> 
> On Aug 4, 2010, at 11:30 AM, Andy Adamson wrote:
> 
> > 
> > On Aug 4, 2010, at 1:06 PM, David Brodbeck wrote:
> > 
> >> 
> >> On Aug 3, 2010, at 7:02 PM, Trond Myklebust wrote:
> >> 
> >>> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
> >>>> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
> >>>>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
> >>>>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
> >>>> 
> >>>>> 2) Why is AUTH_SYS so sacrosanct?
> >>>> 
> >>>> Because it's what almost everyone uses.
> >>> 
> >>> No. It's the _default_. ...and a really really bad default.
> >> 
> >> The problem is the only supported alternative is to set up Kerberos.  This is a lot of work, especially for established sites where it essentially requires every user to change their password during the migration.  It also creates problems with ticket expiration if you have daemons or batch jobs that need continuous access to NFS filesystems.
> > 
> > Changing passwords is a good thing - should be done on a regular basis anyway.
> 
> True, 

Not true.  Forced password changing encourages poor choice of passwords and
other poor practices.
Much better to choose a really good password and only change it when you have
reason to believe that it has been compromised, or when you get bored of the
old one.

(better still is two-factor authentication of course).

NeilBrown
