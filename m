Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:41253 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab2DUBpq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 21:45:46 -0400
Message-ID: <1334972084.2492.722.camel@pico.li.ssimo.org>
Subject: Re: NFSv4 ACLs
From: simo <idra@samba.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeremy Allison <jra@samba.org>, linux-nfs@vger.kernel.org,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        Ondrej Valousek <webserv@s3group.com>
Date: Fri, 20 Apr 2012 21:34:44 -0400
In-Reply-To: <20120420220832.GA1914@fieldses.org>
References: <4F913492.8000402@s3group.cz> <20120420185553.GB32622@samba2>
	 <20120420212627.GA710@fieldses.org> <20120420215945.GE32622@samba2>
	 <20120420220832.GA1914@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-04-20 at 18:08 -0400, J. Bruce Fields wrote: 
> On Fri, Apr 20, 2012 at 02:59:45PM -0700, Jeremy Allison wrote:
> > On Fri, Apr 20, 2012 at 05:26:27PM -0400, J. Bruce Fields wrote:
> > > On Fri, Apr 20, 2012 at 11:55:53AM -0700, Jeremy Allison wrote:
> > > > On Fri, Apr 20, 2012 at 12:04:02PM +0200, Ondrej Valousek wrote:
> > > > > Hi List,
> > > > > 
> > > > > I know this has been asked many times, but I will ask one more time:
> > > > > I would like to export NFSv4 mounted filesystem with Samba and would
> > > > > like to be able to use windows "security tab" in explorer to modify
> > > > > these ACLs.
> > > > > Do I have any chance with Samba on RHEL-5/6?
> > > > 
> > > > Does Linux have local API's to manipulate mounted NFSv4 ACLs ?
> > > > 
> > > > Samba has VFS modules to cope with mapping Windows ACLs onto
> > > > NFSv4 ACLs but currently they only work on AIX, Linux with IBM's
> > > > gpfs and Solaris right now.
> > > > 
> > > > If you can point me a docs showing the library APIs for Linux
> > > > to allow programatic manipulation of NFSv4 ACLs then I can
> > > > make it work on Linux too.
> > > 
> > > It's a bit idiosyncratic, but should be easy enough to handle if you
> > > want, I think: on the linux client, on an nfs4 filesystem, the
> > > "system.nfs4_acl" xattr contains the xdr-encoded ACL as it came in on
> > > the wire (network-byte-order and all).  See the definition of fattr4_acl
> > > in rfc 3530.
> > 
> > I'm sorry, but that *really* *really* sucks. There needs to
> > be an API on the Linux side that implements both RichACLs
> > and NFSv4 ACLs (as they're the same thing essentially).
> 
> Yes, that's the eventual plan.
> 
> The richacl patches still need a little more work, and alas there's
> noone working on them currently as far as I know.
> 
> So if you wanted something that would work now, you could use
> system.nfs4_acl now and later replace that by something that tried
> richacls and then fell back.
> 
> The xdr isn't hard to parse or create--the main problem would be
> figuring out what to do with the names....

Samba does handle id mapping in general and name mapping shouldn't be
too hard to add, SIDs would be easier for us though :-)

> (By the way, is reexporting nfs with samba really going to work well
> anyway?)

Not really, it is generally unsupported, except for read only shares. It
will work in most of the simple cases for writing .. until it breaks :)

Simo.

-- 
Simo Sorce
Samba Team GPL Compliance Officer <simo@samba.org>
Principal Software Engineer at Red Hat, Inc. <simo@redhat.com>

