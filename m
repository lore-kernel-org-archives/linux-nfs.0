From: Chris Newbold <cnewbold@laurelnetworks.com>
Subject: Re: Revisting mmap() and truncate() related corruption
Date: Fri, 06 Feb 2004 08:12:28 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1076073148.14688.150.camel@cnewbold-pc.dhcp.pit.laurelnetworks.com>
References: <1076032596.30653.24.camel@s4>  <4023532E.8040707@medianet.pl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ap5mZ-0003W9-Es
	for nfs@lists.sourceforge.net; Fri, 06 Feb 2004 05:12:31 -0800
Received: from paperclip.laurelnetworks.com ([63.94.127.69] ident=nobody)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ap5mZ-0000IL-2Y
	for nfs@lists.sourceforge.net; Fri, 06 Feb 2004 05:12:31 -0800
To: M.Zieba@medianet.pl
In-Reply-To: <4023532E.8040707@medianet.pl>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 2004-02-06 at 09:41 +0100, Marcin Zieba wrote:

> Chris Newbold wrote:
> [...]
> > 
> > I have also seen mention of this issue in the distcc FAQ, where they
> > recommend using "no_subtree_check" when exporting NFS filesystems, but
> > our servers are NetApps, not Linux. So I don't think this is applicable.

> You can try to change nfs.udp.xfersize to, say, 8192, and on linux, use 
> that size, too. Or try tcp, instead of udp. I'm not saying, that it'll 
> solve the problem, but maybe allow you to narrow the problem.

>From what I've gathered, there are (at least) two issues with mmap() and
NFS: one involving rename() and another with truncate(). It seems like
the "no_subtree_check" recommendation for Linux servers was directed at
the rename() problem.

We're having the truncate() problem.

Researching that original thread a little more, I see that Steve Dickson
(who originally posted a candidate patch for the problem here) found
that this problem persisted regardless of whether UDP or TCP was used.
FWIW...

-Chris

-- 
====( Chris Newbold  <cnewbold@laurelnetworks.com> )==========================
      Laurel Networks, Inc. voice: +1 412 809 4200 fax: +1 412 809 4201
"If you fool around with a thing for very long you will screw it up." --Murphy
------------------------------------------------------------------------------



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
