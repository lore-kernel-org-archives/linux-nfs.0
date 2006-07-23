From: Sam Falkner <Sam.Falkner@Sun.COM>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
 draft-ietf-nfsv4-acls-00 not ready
Date: Sun, 23 Jul 2006 09:45:59 -0600
Message-ID: <D001EC84-1F54-4C5D-B261-582B9E777FCA@Sun.COM>
References: <992BA60650F1584BA63E339312CE420305B9456D@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	"Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	"Pawlowski,  Brian" <beepy@netapp.com>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G4g9M-00074e-Bs
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 08:45:48 -0700
Received: from brmea-mail-1.sun.com ([192.18.98.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G4g9L-0005cm-KC
	for nfs@lists.sourceforge.net; Sun, 23 Jul 2006 08:45:48 -0700
Received: from fe-amer-10.sun.com ([192.18.108.184])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id
	k6NFjfQ9019633
	for <nfs@lists.sourceforge.net>; Sun, 23 Jul 2006 09:45:46 -0600 (MDT)
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
	(Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
	id <0J2V00L014YUTF00@mail-amer.sun.com>
	(original mail from Sam.Falkner@Sun.COM) for nfs@lists.sourceforge.net;
	Sun, 23 Jul 2006 09:45:41 -0600 (MDT)
In-reply-to: <992BA60650F1584BA63E339312CE420305B9456D@exsvl02.hq.netapp.com>
To: "Yoder, Alan" <agy@netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Jul 21, 2006, at 11:16 AM, Yoder, Alan wrote:

> A whisper of warning from experience in other
> standards bodies (SNIA), where we have things
> like this in our spec.  It's dangerous to
> place informational algorithms in otherwise
> normative text, even if they're labeled as
> informational.  They tend to get enshrined in
> plugfest procedures, independent certification
> or test suites, and such, and then they're not
> really informational any more.  Even the informal
> "language" they're written in can get set up
> on a pedestal.
>
> I realize this may not be welcome advice, but I'd
> advise either keeping these things out of the spec,
> or doing the work to formalize them, verify them,
> and make them normative.  Or both.

I have created Issue 93 to resolve whether or not the algorithms  
should be included in the minorversion1 document.  I vote "no" on  
their inclusion, but it's only a slight preference.  I do not want to  
make the current algorithms normative.

- Sam

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
