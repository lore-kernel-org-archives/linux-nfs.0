From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 07 Mar 2007 17:56:48 -0500
Message-ID: <EXNANE0169aZbLAX3cf0000007a@exnane01.hq.netapp.com>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<20070307224054.b2cbc294.simon.peter@gmx.de>
	<17903.14864.866148.254685@notabene.brown>
	<EXNANE01okLQ8aZRhQd00000077@exnane01.hq.netapp.com>
	<17903.16692.884318.142587@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP54Y-0000OJ-OR
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:57:26 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP54Z-0001NY-NO
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:57:28 -0800
In-Reply-To: <17903.16692.884318.142587@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<20070307224054.b2cbc294.simon.peter@gmx.de>
	<17903.14864.866148.254685@notabene.brown>
	<EXNANE01okLQ8aZRhQd00000077@exnane01.hq.netapp.com>
	<17903.16692.884318.142587@notabene.brown>
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

At 05:48 PM 3/7/2007, Neil Brown wrote:
>No.  The mode/acl on anything isn't interesting to mountd.  If the
>client has access to a file, it gets access, if not: not.  That is all
>handled by nfsd.
>And remember that if you "chmod 0" a directory, that doesn't remove
>access from people with files in the directory already open.

Well, if mountd isn't running as root and the export point is mode 0,
then it can't be exported because the daemon can't stat it, right?

Corner case, I guess, maybe mountd can't be non-root. Agreed on
the revoke-when-open, of course.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
