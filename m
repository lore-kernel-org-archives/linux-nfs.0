From: Pete Zaitcev <zaitcev@redhat.com>
Subject: 1279 mounts
Date: Thu, 25 Apr 2002 16:21:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <aa9orr$fp0$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, zaitcev@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=devserv.devel.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170pjp-0006bQ-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Apr 2002 13:21:09 -0700
To: nfs@lists.sourceforge.net
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

I updated my patch that allows to mount unholy numbers of volumes.
The old version was for 2.4.9 and did not apply anymore.
I split the unnamed majors patch and the NFS patch.
Also, CONFIG_ option is gone, because it made the code ugly.

Majors part:
 http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-unmaj.diff
NFS part:
 http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-nores.diff
Userland for NFS:
 http://people.redhat.com/zaitcev/linux/util-linux-2.11q-nores1.diff

Is anyone actually interested? Random people periodically ask
me for patches, get them and disappear into the void. I hear
nothing good or bad (well, nothing since Trond reviewed it
several months ago, and also someone found a conflict with NFS
server code, since fixed). I am thinking about submitting,
but if users do not ask, why add extra bloat and negotiate
with LANANA...

-- Pete

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
