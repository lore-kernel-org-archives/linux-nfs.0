From: Levent Serinol <lserinol@yahoo.com>
Subject: URGENT !!!! lockd eating up CPU
Date: Wed, 27 Mar 2002 12:25:40 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020327202540.79642.qmail@web11601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from web11601.mail.yahoo.com ([216.136.172.53])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qJzL-0006yp-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 12:25:43 -0800
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

Hi,

We are tested 3 Linux Distributions (RedHat 7.2, SuSE
Linux 7.3,
Caldera Open Linux Server 3.1.1) with latest updates.
However after 7 or 8 hours later lockd is staring to
eat up our cpu.
We have 4 Solaris NFS clients that using Linux NFS
server. Every client
creates or reads a lot of files (aprrox. 26k) on NFS
server. It is
very common that every file is updated,read or deleted
 by all
clients.

After 7 or 8 hours later lockd uses all available cpu
sys time.

Is this a known bug ?

Best Regards,

=====
Levent Serinol
ICQ#  : 9792343

#exclude <windows.h>
"Trust me.  I know what I'm doing."
-- Sledge Hammer

__________________________________________________
Do You Yahoo!?
Yahoo! Movies - coverage of the 74th Academy Awards®
http://movies.yahoo.com/

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
