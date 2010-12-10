Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52226 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756684Ab0LJTSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 14:18:02 -0500
Date: Fri, 10 Dec 2010 14:17:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <thomas@netapp.com>
Cc: Spencer Shepler <spencer.shepler@gmail.com>,
        "'Trond Myklebust'" <Trond.Myklebust@netapp.com>,
        "'Spelic'" <spelic@shiftmail.org>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101210191758.GD5014@fieldses.org>
References: <1291156414.4393.2.camel@heimdal.trondhjem.org>
 <20101130223627.GC5054@fieldses.org>
 <20101201135740.0d3b5948@notabene.brown>
 <1291173002.7694.7.camel@heimdal.trondhjem.org>
 <20101201162912.GC6832@fieldses.org>
 <99BBEF51-7EB1-4BAA-9B12-F0F98A629C74@netapp.com>
 <1291331885.2915.1.camel@heimdal.trondhjem.org>
 <03e401cb9278$ad554ad0$07ffe070$@gmail.com>
 <20101208001548.GA30196@fieldses.org>
 <3FD238C0-0A97-4EEE-ACE6-A0547E2559AF@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3FD238C0-0A97-4EEE-ACE6-A0547E2559AF@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 10, 2010 at 11:00:08AM -0800, Thomas Haynes wrote:
> 
> On Dec 7, 2010, at 4:15 PM, J. Bruce Fields wrote:
> 
> > 
> > (I see AUTH_SYS as a different issue.  It's unfortunately true that
> > AUTH_SYS has effectively turned out to be required-to-implement even if
> > it wasn't meant to be, so maybe the spec's out of line with reality
> > there; but I haven't heard of that causing any practical
> > problems--whereas "why does ls show all users as nobody after an upgrade
> > to NFSv4" is a FAQ.)
> 
> If everyone were to adopt this approach to solve the FAQ, then wouldn't we
> want it to be specified to make sure that interoperability was maximized?

Sorry for the confusion--that last paragraph was just about AUTH_SYS,
not about user/group-naming.

Sure, I'd be happy to propose changes to the user/group-naming (which is
all in section 5.8 of 3530, I think, or is there some scattered
elsewhere?)

--b.
