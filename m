From: Juan Gomez <juang@us.ibm.com>
Subject: RedHat nfs-utils-0.3.3.drop-privs.patch problems.
Date: Tue, 29 Oct 2002 11:33:25 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFABA5F7C6.E14F63CE-ON87256C61.006A538C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 186c8m-0008Ej-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 11:35:04 -0800
To: linux-kernel@vger.kernel.org
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>





I am having trouble when I apply this patch to statd for the following
reason. After the patch does drop_privs() to switch from root to rpcuser
statd_get_socket() is called and it fails to bind to reserved ports
(bindresvport()) as rpcuser is not root. Later when statd tries to notify
lockd of a server going down/back up for example (at the NFS client side)
lockd (in the kernel) refuses to take the notification because it is coming
from a non-priv port (which I think is fine)...

Is this a well-known problem or am I just doing something wrong here?

Regards, Juan



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
