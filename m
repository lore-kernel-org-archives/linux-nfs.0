From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [NFS] libnfsidmap
Date: Wed, 21 Nov 2007 08:11:14 -0500
Message-ID: <4d569c330711210511x3f06562cp1a5886eaeaaea953@mail.gmail.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
	<1195024312.19850.130.camel@serendib.melbourne.sgi.com>
	<4d569c330711140659q2ba19b03n481c3360a9373991@mail.gmail.com>
	<1195122558.19850.146.camel@serendib.melbourne.sgi.com>
	<4d569c330711150612n57d4f4deud19532569b2214d8@mail.gmail.com>
	<1195644766.19850.252.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Harshula <harshula@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IupMD-0000L6-1J
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 05:11:09 -0800
Received: from rv-out-0910.google.com ([209.85.198.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IupMI-0005Jf-UB
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 05:11:15 -0800
Received: by rv-out-0910.google.com with SMTP id g11so7798525rvb
	for <nfs@lists.sourceforge.net>; Wed, 21 Nov 2007 05:11:14 -0800 (PST)
In-Reply-To: <1195644766.19850.252.camel-2WabGjdRN2LRvmHwrWB8BmjR7Gm6iKkz0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 21, 2007 6:32 AM, Harshula <harshula@sgi.com> wrote:
> On Thu, 2007-11-15 at 09:12 -0500, Kevin Coffman wrote:
> > On Nov 15, 2007 5:29 AM, Harshula <harshula@sgi.com> wrote:
>
> > > In practise, what are the "other cases" where a failed
> > > nfs4_gss_princ_to_ids() lookup needs to be mapped to 'nobody'?
> >
> > You have cross-realm Kerberos trusts set up.  A user from a different
> > Kerberos realm comes to your server and you have no local mapping for
> > that user.
>
> Can the KDCs be setup to handle this case?

If you are asking if the KDC can be configured to not give such users
a ticket, the answer is no.  It is up to the application (NFS in this
case) to enforce authorization,  Kerberos only does authentication.
(This may be another case for a configuration option.  See below.)

> > A new local user is created, but has not yet been placed in the mappings.
>
> This case should fail.

My opinion is that they have successfully authenticated, and should
not be denied all access because there is no mapping.  This should
probably be a configurable option.

K.C.

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

