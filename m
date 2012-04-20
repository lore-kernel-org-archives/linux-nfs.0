Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:34514 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754984Ab2DTWFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 18:05:49 -0400
Date: Fri, 20 Apr 2012 14:59:45 -0700
From: Jeremy Allison <jra@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeremy Allison <jra@samba.org>, Ondrej Valousek <webserv@s3group.com>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACLs
Message-ID: <20120420215945.GE32622@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <4F913492.8000402@s3group.cz>
 <20120420185553.GB32622@samba2>
 <20120420212627.GA710@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120420212627.GA710@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 20, 2012 at 05:26:27PM -0400, J. Bruce Fields wrote:
> On Fri, Apr 20, 2012 at 11:55:53AM -0700, Jeremy Allison wrote:
> > On Fri, Apr 20, 2012 at 12:04:02PM +0200, Ondrej Valousek wrote:
> > > Hi List,
> > > 
> > > I know this has been asked many times, but I will ask one more time:
> > > I would like to export NFSv4 mounted filesystem with Samba and would
> > > like to be able to use windows "security tab" in explorer to modify
> > > these ACLs.
> > > Do I have any chance with Samba on RHEL-5/6?
> > 
> > Does Linux have local API's to manipulate mounted NFSv4 ACLs ?
> > 
> > Samba has VFS modules to cope with mapping Windows ACLs onto
> > NFSv4 ACLs but currently they only work on AIX, Linux with IBM's
> > gpfs and Solaris right now.
> > 
> > If you can point me a docs showing the library APIs for Linux
> > to allow programatic manipulation of NFSv4 ACLs then I can
> > make it work on Linux too.
> 
> It's a bit idiosyncratic, but should be easy enough to handle if you
> want, I think: on the linux client, on an nfs4 filesystem, the
> "system.nfs4_acl" xattr contains the xdr-encoded ACL as it came in on
> the wire (network-byte-order and all).  See the definition of fattr4_acl
> in rfc 3530.

I'm sorry, but that *really* *really* sucks. There needs to
be an API on the Linux side that implements both RichACLs
and NFSv4 ACLs (as they're the same thing essentially).

Both GPFS and ZFS have defined API's to get and set
ACLs. Just sticking them on a "system.nfs4_acl" xattr
is a cop-out of monstrous proportions (and the kind of
crap that we have to pull :-).

Jeremy.
