From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Locking patches (generic & nfs)
Date: Tue, 23 Jul 2002 17:27:38 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <23054.6477287591$1027438491@news.gmane.org>
References: <20020719101950.A15819@suse.de> <shsy9c27asf.fsf@charged.uio.no> <20020723170615.D1869@suse.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_2AKPHME3BAIGNDN4KA07"
Cc: linux-kernel@vger.kernel.org,
 nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X1Zo-0006Hi-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 08:27:53 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20020723170615.D1869@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--------------Boundary-00=_2AKPHME3BAIGNDN4KA07
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8bit

On Tuesday 23 July 2002 17:06, Olaf Kirch wrote:

> But as it is today, all blocked locks get inserted at the end of the
> list because time_before_eq does a signed comparison! With the unpatched
> code, when you have a blocked lock, and the conflicting lock is removed,
> lockd will never send out a GRANTED_MSG. Because the blocked lock is at the
> end of the list, and never picked up.

Fair enough: I see the bug now.

So why could we not do something like the following instead? This just ensures 
that we always leave the NLM_NEVER stuff at the end of the list which should 
suffice to keep nlmsvc_retry_blocked() happy.

Cheers,
  Trond

--------------Boundary-00=_2AKPHME3BAIGNDN4KA07
Content-Type: text/plain;
  charset="iso-8859-15";
  name="fix_svclock.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="fix_svclock.dif"

--- linux/fs/lockd/svclock.c.orig	Tue Feb  5 08:52:37 2002
+++ linux/fs/lockd/svclock.c	Tue Jul 23 17:15:12 2002
@@ -64,7 +64,7 @@
 	if (when != NLM_NEVER) {
 		if ((when += jiffies) == NLM_NEVER)
 			when ++;
-		while ((b = *bp) && time_before_eq(b->b_when,when))
+		while ((b = *bp) && time_before_eq(b->b_when,when) && b->b_when != NLM_NEVER)
 			bp = &b->b_next;
 	} else
 		while ((b = *bp))

--------------Boundary-00=_2AKPHME3BAIGNDN4KA07--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
