From: Andreas Behnert <abehn@gmx.net>
Subject: statd error messages - do I need a more recent nfs-utils version?
Date: Tue, 15 Apr 2003 17:53:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E9C2AF1.5000003@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 195SkU-0003UA-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Apr 2003 08:53:30 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

server was running Debian 3.0r1 + kernel 2.2.20 (vanilla) and
some days ago because of various reasons I had to upgrade to
kernel 2.4.x ASAP. Because of some knfsd related fixes in 2.4.21-pre
I did some stability tests and after that I installed 2.4.21-pre7
on the server. With the new kernel statd often causes error messages
in the server log, for instance:

(srv = server
  and three drifferent clients as an example:
   .105 = AIX 5.1-ML2
   .107 = HP-UX 11.0U
   .114 = IRIX 6.5.15)

~~~snip~~~
srv rpc.statd[475]: Received erroneous SM_UNMON request from srv for
  x.x.x.105
srv rpc.statd[475]: Received erroneous SM_UNMON request from srv for
  x.x.x.107
srv rpc.statd[475]: Received erroneous SM_UNMON request from srv for
  x.x.x.114
~~~snip~~~

Are these messages somehow important? With kernel 2.2.20 there were no
such messages.
Debian Woody comes with nfs-utils 1.0 - maybe these messages are related
to this older utils version and I have to update nfs-utils to 1.0.3?
Building the Debian package wouldn't be a problem ...


Regards,
Andreas



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
