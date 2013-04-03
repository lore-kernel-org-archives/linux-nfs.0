Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34817 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761875Ab3DCNoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 09:44:12 -0400
Date: Wed, 3 Apr 2013 09:44:07 -0400
To: Simo Sorce <simo@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>, Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130403134407.GB13951@fieldses.org>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
 <20130402183907.GB18900@umich.edu>
 <1364928519.2660.1279.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364928519.2660.1279.camel@willson.li.ssimo.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 02, 2013 at 02:48:39PM -0400, Simo Sorce wrote:
> On Tue, 2013-04-02 at 14:39 -0400, Jim Rees wrote:
> > Simo Sorce wrote:
> > 
> >   No this is not what I am saying.
> >   The client uses the fully qualified name at the mount command but due to
> >   the use of a PTR lookup it is fooled into acquiring a ticket for the
> >   wrong server which will then happily allow you to connect.
> >   
> >   Currently:
> >   The mount command tells the kernel both the server name
> >   'secure.server.name' and it's IP address 1.2.3.4 however rpc.gssd
> >   currently completely ignored the server name passed in by the mount
> >   command (see the 'dummy' variable) and instead uses the ip address to do
> >   a reverse lookup.
> >   
> >   PTR lookup of 1.2.3.4 --- MITM ---> public.server.com
> >   
> >   Then it uses the retrieved name (public..) to construct the GSSAPI name
> >   it wants to connect to, the result is that the name
> >   nfs@public.server.name is constructed instead of the requested
> >   nfs@secure.server.com that should be requested.
> >   
> >   So the client does ask for the right server but can be easily tricked
> >   into connecting to another one.
> >   
> >   Kerberos itself *is* correctly identifying the server, it's rpc.gssd
> >   that opened it'sself to being fooled before involving Kerberos.
> > 
> > Ok, I think I understand now. I suggest adding some of that text into the
> > commit log.
> 
> To be honest this is a well known problem in the kerberos community, I
> will see if I can find a public text that references this problem and
> add a link to it in the commit log ?
> 
> It's a bit of a long explanation otherwise ... maybe I can point at this
> thread in the archives ?
> 
> >  And stop using the term "mitm". A mitm attack is used to
> > convince both ends of a connection that they are talking to each other. DNS
> > is not a mutually authenticated exchange.
> 
> Well it is still a sort of Man in the Middle, as you also have to
> redirect communications (nfsv4 uses TCP) for it to be effective, it is
> just not exploiting a crypto issue.

Like Jim I don't understand how that fits the definition of a "man in
the middle" attack.

I also wonder whether "GSSAPI name" is specialized jargon.  And I don't
understand what you mean by "tries to avoid" reverse lookups--does it
use them or not?  How about:

	With this option, gssd expects the name given on the mount
	command line to be exactly the name that the server
	authenticates as.  This option is strongly recommended.

	Without this option, gssd will instead do a reverse lookup on
	the server's IP address to decide what name it should use.  This
	is vulnerable to attacks on DNS, and is fragile in cases where
	reverse DNS (PTR) records are not set up correctly.

--b.
