From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [Storage_sig] Re: Question on bug tracking for NFSv4 work
Date: Fri, 10 Dec 2004 10:52:32 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B7F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <storage_sig@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ccpsj-0007By-R5
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 10:52:45 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ccpsd-0007R9-Kw
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 10:52:45 -0800
To: "Bryce Harrington" <bryce@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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

> So I think that keeping the bugs themselves up to date=20
> (updating status, etc.) would be our principle challenge.

my concern exactly.  i wonder about the effectiveness v. overhead ratio
because we won't have 100% developer participation.  i wonder who will
define and enforce the tracking process.  ie. bug databases are great in
theory, but in practice, sometimes there are big problems...

we may not "lose" bugs if we record them in the database, but we may
"lose" them because they get ignored after they are added.  what kind of
resources are available to manage (police) the process?  do we have a
triage mechanism for incoming bugs?

is this for just development testers, or do we accept bug reports from
users, NFS implementation partners, or the Linux distributors?  are we
interested solely in NFSv4 issues, or do we want reports on
v2/3-specific problems, side band protocol issues, problems occuring in
advanced development projects, or RPC SEC issues?  do we have a good
reason to exclude any of these bug types?

my position is that i would like this to work, as bruce would.  but i
would also like not to waste time if there is a good chance that a bug
database will be ineffective and eventually abandoned, as both citi's
NFSv4 cvstrac and SF's NFS bug database were.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
