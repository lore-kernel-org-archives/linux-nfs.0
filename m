From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 07 Mar 2007 15:31:49 -0500
Message-ID: <EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP2o9-0001YN-D3
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:32:21 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP2oA-0003UO-5r
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:32:23 -0800
In-Reply-To: <20070307194418.97fee0ec.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
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

At 01:44 PM 3/7/2007, Simon Peter wrote:
>> Could we cache the stat information in the export and then
>> double-check it if necessary when there's a match?  Or is there some
>> way we could get the kernel to keep that cached for us?
>
>I could certainly cook up a patch for mountd to cache that information
>on its own. I don't have too much clue about how the kernel does its
>cacheing, though. If it's useful to do that directly in mountd, I could
>get my hands on it.

This sounds like a job for inotify. The mountd could stat the export root
and use inotify_add_watch(2) to keep an eye on it to see if the stat
contents changed. Since the export already has a reference, it doesn't
seem offhand like it would change things much, operationally. Of course,
making mountd depend on an optional facility might be an issue, but it
could always fall back to the current behavior.

You probably don't want to sign up for enhancing the in-kernel export
cache. :-) Let's just say it's a bit mysterious, especially its interaction
with mountd.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
