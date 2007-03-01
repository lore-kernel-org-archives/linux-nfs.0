From: M A Young <m.a.young@durham.ac.uk>
Subject: Re: NFS client fcntl locks going missing on FC6
Date: Thu, 1 Mar 2007 00:51:27 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0703010031330.18281@vega4.dur.ac.uk>
References: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
	<45E073AB.2040005@RedHat.com>
	<Pine.LNX.4.58.0702241754030.21958@vega4.dur.ac.uk>
	<Pine.LNX.4.58.0702250017400.18669@vega3.dur.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Steve Dickson <SteveD@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMZWL-0001hz-6m
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 16:51:46 -0800
Received: from hermes2.dur.ac.uk ([129.234.8.21])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMZWL-0007wZ-Pz
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 16:51:47 -0800
In-Reply-To: <Pine.LNX.4.58.0702250017400.18669@vega3.dur.ac.uk>
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

I have found out what was causing the bug I was seeing. The do_setlk
function of fs/nfs/file.c creates a local lock if the remote lock attempt
was blocked and then interrupted, supposedly so that the remote lock is
removed when the process exits. Unfortunately by this stage the lock has
forgotten how to do this, and if the process tries again for the same
remote lock and succeeds in getting it, the system reuses the existing
local only lock rather than creating a new one, which means that there is
apparently nothing using the owner records storing the (new) svid, and
this is information is discarded. As a result, when the file is unlocked,
there is no record of the svid that was used, so the unlock attempt uses a
new svid which of course fails, and the file is never unlocked.
I have attached a patch to the RedHat bugzilla bug (229469)
https://bugzilla.redhat.com/bugzilla/attachment.cgi?id=148974
which under limited testing fixes the problem I was seeing by not creating
the local lock if it has no hope of removing any possible remote one,
though I suspect more thought could yield a better patch.

	Michael Young

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
