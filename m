From: jason andrade <jason@dstc.edu.au>
Subject: linux nfs still limited to rsize=1024 ?
Date: Fri, 2 Aug 2002 01:01:53 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.44.0208020057540.20146-100000@sunburn.dstc.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from piglet.dstc.edu.au ([130.102.176.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aHSm-0002X3-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 08:02:04 -0700
Received: from sunburn.dstc.edu.au (sunburn.dstc.edu.au [130.102.176.16])
	by piglet.dstc.edu.au (8.12.3/8.12.3) with ESMTP id g71F1rSQ011298
	for <nfs@lists.sourceforge.net>; Fri, 2 Aug 2002 01:01:53 +1000 (EST)
To: mailto: ;
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

I've been trying to use Linux NFS in read only mode with a block
size of > 1024, for around 2 years now.

I've just rebooted into a redhat linux 2.4.18-5 kernel and on
a whim decided to try rsize=8192 to see if this has been
"fixed".  nope, it hasn't.  df hangs for me with any nfs mount
using rsize > 1024.  if i drop it back to that, it works fine.

I'm kind of stunned that even with gigabit interfaces and MTU's
of 9000, i've still got to stay with 1K packets under nfs.

(both client and server have gigE and 9000 mtus)

The server is a redhat linux box running 2.4.18-5 also, exporting
about 1.2Tb read only.  The clients mount using nfs over udp,
since nfs/tcp doesn't seem to be (well?) supported or recommended in
the redhat kernels.


regards,

-jason



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
