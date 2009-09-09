Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33242 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbZIITmO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 15:42:14 -0400
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        steved@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
	 <20090805144540.12866.22084.stgit@matisse.1015granger.net>
	 <20090805174811.GB9944@fieldses.org>
	 <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
	 <20090805181545.GF9944@fieldses.org>
	 <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
	 <1249507356.5428.11.camel@heimdal.trondhjem.org>
	 <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
	 <1249515004.5428.34.camel@heimdal.trondhjem.org>
	 <20090909142945.755da393@tlielax.poochiereds.net>
	 <1252521599.8722.53.camel@heimdal.trondhjem.org>
	 <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>
Content-Type: text/plain
Date: Wed, 09 Sep 2009 15:42:07 -0400
Message-Id: <1252525327.8722.81.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-09-09 at 15:17 -0400, Chuck Lever wrote:
> On Sep 9, 2009, at 2:39 PM, Trond Myklebust wrote:
> The old statd still exists in nfs-utils.  The new statd is an entirely  
> separate component.  Distributions can continue to use the old statd  
> as long as they want.  This is a red herring.

Bullshit. If they are adding IPv6 support, then they will have to
upgrade at some point.

> > Simplicity is another reason. WTF do we need a full SQL database, when
> > all we want to do is store 2 pieces of data (a hostname and a cookie)?
> > It isn't as if this has been a major problem for us previously.
> 
> Because we are not storing just a hostname and a cookie.  We are  
> storing several different data items for each host, and we need to  
> search over the records, and provide uniqueness constraints, and  
> handle data conversion (for binary data like the cookie, for string  
> data like the hostname, and for integers, like the prog/vers/proc  
> tuple).  We need to store them durably on persistent storage to have  
> some protection against crashes.  These are all things that an  
> embedded database can do well, and that we therefore don't have to  
> code ourselves.

Speaking of red herrings. Why are we adding all this crap?

This is a legacy filesystem! We shouldn't not be rewriting NLM/NSM from
scratch, just add minimal support for IPv6.

> >>>> In any event, it's not just sync(2) that is a problem.  sync(2) by
> >>>> itself is a boot performance problem, but it's the combination of
> >>>> rename and sync that is known to be especially unreliable during
> >>>> system crashes.  Statd, being a crash monitor, shouldn't depend on
> >>>> rename/sync to maintain persistent data in the face of system
> >>>> instability.  I'd call that a real reason to use something more  
> >>>> robust.
> >>>
> >>> What are you talking about? Is this about the truncate + rename  
> >>> issue
> >>> leaving empty files upon a crash?
> >>> That issue is solved trivially by doing an fsync() before you  
> >>> rename the
> >>> file. That entire discussion was about whether or not existing
> >>> applications should be _required_ to do this kind of POSIX pedantry,
> >>> when previously they could get away without it.
> >>>
> >>> IOW: that issue alone does not justify replacing the current  
> >>> simple file
> >>> based scheme.
> >>>
> >>
> >> There are other reasons, not to use the simple file-based scheme  
> >> too...
> >>
> >> Internationalized domain names will be easier to deal with via  
> >> sqlite3,
> >> for instance.
> >
> > Please explain...
> 
> IPv6 is used in Asia, where they almost certainly need to use non- 
> ASCII characters in their hostnames.  Internationalized domain names  
> are stored in double-wide character sets.  To provide reliable support  
> for IDNs in statd, we will have to guarantee somehow that we can store  
> an IDN as a file name (if we want to stay with the current scheme), no  
> matter what file system is used for /var.

So, what's stopping us? These are POSIX filesystems. They can store any
filename as long as it doesn't contain '/' or '\0'.

> What's more, multi-homed host support will need to store multiple  
> records for the same hostname.  The mon_name is the same, but my_name  
> is different, for each of these records.  So we could do that by  
> adding more than one line in each hostname file, but it's also a  
> simple matter to set this up in SQL.
> 
> When we want to have statd remember things like multiple addresses for  
> the same hostname, or whether the remote is a client or server, we  
> will need to make more adjustments to the files.
> 
> As we get more and more new requirements, why lock ourselves into the  
> current on-disk format?  Using statd means we can store new fields and  
> new records without any backwards-compatibility issues.  It's all  
> handled by the database code.  So, we can think about the high level  
> problem of getting statd to behave correctly rather than worry about  
> the details of exactly how we are going to get the next data item  
> stored in our current files in a backward compatible way.

Again. This is a legacy filesystem. Why are we adding requirements?

> >> Certainly we could code this up ourselves, but what's the benefit to
> >> doing that when we have a perfectly good data storage engine  
> >> available?
> >
> > Why change something that works???? Rewriting from scratch is _NOT_  
> > the
> > Linux way, and has usually bitten us hard when we've done it.
> 
> Because we are adding a bunch of new feature requirements.   
> Internationalized domain names, multi-homed host support, IPv6 and TI- 
> RPC, fast boot times, keeping better track of remote host addresses,  
> keeping track of which remotes are clients and which are servers, and  
> support for sending notifications via TCP all require significant  
> modifications to this code base.
> 
> At some point you have to look at the code you have, and decide it's  
> simply not going to be adequate, going forward.
> 
> > The 2.6.19 rewrite of the kernel mount code springs to mind...
> 
> One can just as easily argue that we've been bitten hard precisely  
> because we've let things rot, or because we have inadequate testing  
> for these components.
> 
> Another red herring, and especially annoying because you've known I  
> was rewriting statd for months.  Only now, when I'm done, do you say  
> "rewriting is not the Linux way."

I have _NEVER_ agreed to a rewrite of the storage formats. You sprang
this crap on me a month ago, and I made my feelings quite clear then.


