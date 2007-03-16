From: Steve Dickson <SteveD@redhat.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Fri, 16 Mar 2007 10:03:43 -0400
Message-ID: <45FAA3BF.3030204@RedHat.com>
References: <17914.20117.186786.830574@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSD23-0004hY-BB
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:03:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSD23-0007Hr-7D
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:03:49 -0700
In-Reply-To: <17914.20117.186786.830574@notabene.brown>
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



Neil Brown wrote:
> A particular exception is fixes for mount.nfs w.r.t. handing of
> MS_REMOUNT.  I haven't figured out what that is all about yet and it
> is getting late. :-)
Well the main purpose of the patch is to stop ment->mnt_opts
from being re-freed during the remount path:

+	/*
+	 * Note: free(ment->mnt_opts) happens in discard_mntentchn()
+	 * via update_mtab() on remounts
+	 */
+	 if (!remount)
+	 	free(ment->mnt_opts);
+}

The second part the patch is basically cleaning
up how the default nfs version is set... preparing
for the day when v4 is the default...

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
