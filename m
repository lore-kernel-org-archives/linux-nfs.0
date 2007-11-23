From: Harshula <harshula@sgi.com>
Subject: Re: [NFS] libnfsidmap
Date: Fri, 23 Nov 2007 15:00:49 +1100
Message-ID: <1195790449.5730.12.camel@serendib.melbourne.sgi.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
	<4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
	<1195122558.19850.146.camel@serendib.melbourne.sgi.com>
	<4d569c330711150612n57d4f4deud19532569b2214d8@mail.gmail.com>
	<1195644766.19850.252.camel@serendib.melbourne.sgi.com>
	<4d569c330711210511x3f06562cp1a5886eaeaaea953@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IvPir-0000cJ-SM
	for nfs@lists.sourceforge.net; Thu, 22 Nov 2007 20:00:58 -0800
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19x24KObIHiZaVHrnDcK1x93fhKJOqMXSU=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IvPiw-0004UW-N5
	for nfs@lists.sourceforge.net; Thu, 22 Nov 2007 20:01:03 -0800
In-Reply-To: <4d569c330711210511x3f06562cp1a5886eaeaaea953-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Kevin,

On Wed, 2007-11-21 at 08:11 -0500, Kevin Coffman wrote:
> On Nov 21, 2007 6:32 AM, Harshula <harshula@sgi.com> wrote:
> > On Thu, 2007-11-15 at 09:12 -0500, Kevin Coffman wrote:

> > > You have cross-realm Kerberos trusts set up.  A user from a different
> > > Kerberos realm comes to your server and you have no local mapping for
> > > that user.
> >
> > Can the KDCs be setup to handle this case?
> 
> If you are asking if the KDC can be configured to not give such users
> a ticket, the answer is no.

No, I was referring to cross-realm authentication:
http://www.faqs.org/faqs/kerberos-faq/general/section-18.html

> > > A new local user is created, but has not yet been placed in the mappings.
> >
> > This case should fail.
> 
> My opinion is that they have successfully authenticated, and should
> not be denied all access because there is no mapping.  This should
> probably be a configurable option.

If it is going to be configurable, I hope the default will be the
'secure' option of disallowing users without mappings. If a new local
user is created and there is no mapping, then it's either a
misconfiguration or intentional. We should not be catering for the
misconfiguration.

cya,
#


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

