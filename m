From: Brian Tinsley <btinsley@emageon.com>
Subject: EJUKEBOX and Java
Date: Tue, 02 Apr 2002 10:50:18 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CA9E14A.2010903@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sRUM-0004nG-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Apr 2002 08:50:30 -0800
Received: from emageon.com (jserv001.emageon.com [10.10.10.18])
	by studio-ts2.emageon.com (Emageon Mail Service) with ESMTP id g32GoIB31415
	for <nfs@lists.sourceforge.net>; Tue, 2 Apr 2002 10:50:18 -0600
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

While I'm starting to investigate, I just wanted to post my quandry here:


We have a Linux-based Java application (2.4.17 kernel, IBM JVM) that 
accesses files over an NFS v3 mount (UDP) to a Solaris 8 NFS server that 
exports a SAM-FS filesystem (Sun's HSM product). It seems that whenever 
our application requests access to a file that resides on tape, it 
encounters a temporary deadlock condition. We know that the NFS server 
is returning EJUKEBOX at this point and it seems that once data begins 
to flow back to the client, the deadlock releases. Could this be in any 
way due to changing signal handling in the nfs3_rpc_wrapper function? 
The Java virtual machine does use signals for internal purposes; I 
believe libpthread does so as well. Any thoughts on this are more than 
welcome.

-- 
Brian Tinsley
Senior Systems Engineer
Emageon




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
