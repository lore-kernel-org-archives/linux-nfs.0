From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: nfs-utils 1.0.11 still seems broken
Date: Thu, 1 Mar 2007 00:03:28 +0100
Message-ID: <20070228230327.GA3518@uio.no>
References: <20070228104726.GA6866@uio.no>
	<17894.2057.828174.464967@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMXqU-0007ZJ-Bn
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 15:04:26 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMXqV-0004o9-2L
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 15:04:28 -0800
In-Reply-To: <17894.2057.828174.464967@notabene.brown>
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

On Thu, Mar 01, 2007 at 09:54:01AM +1100, Neil Brown wrote:
> Can you try 1.0.12?? 1.0.11 had some silly stuff in it, but I'm not
> sure it would cause the problem you are seeing..

1.0.12 seems to solve the issue for me -- I rebooted the nfsroot machine, and
it comes up perfectly. That's odd, given the diff...

Oh well, on to push it into Debian.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
