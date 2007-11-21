From: Harshula <harshula@sgi.com>
Subject: Re: [NFS] libnfsidmap
Date: Wed, 21 Nov 2007 22:32:46 +1100
Message-ID: <1195644766.19850.252.camel@serendib.melbourne.sgi.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
	<4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
	<1195122558.19850.146.camel@serendib.melbourne.sgi.com>
	<4d569c330711150612n57d4f4deud19532569b2214d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iunpo-0007GW-1B
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 03:33:36 -0800
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18mNg6K4NG1iV0cm8znsSS0KhUPjqM9luw=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iunpr-0006NO-SS
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 03:33:42 -0800
In-Reply-To: <4d569c330711150612n57d4f4deud19532569b2214d8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2007-11-15 at 09:12 -0500, Kevin Coffman wrote:
> On Nov 15, 2007 5:29 AM, Harshula <harshula@sgi.com> wrote:

> > In practise, what are the "other cases" where a failed
> > nfs4_gss_princ_to_ids() lookup needs to be mapped to 'nobody'?
> 
> You have cross-realm Kerberos trusts set up.  A user from a different
> Kerberos realm comes to your server and you have no local mapping for
> that user.

Can the KDCs be setup to handle this case?

> A new local user is created, but has not yet been placed in the mappings.

This case should fail.

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

