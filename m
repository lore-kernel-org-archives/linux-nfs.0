From: Kumaran Rajaram <kums@CS.MsState.EDU>
Subject: Problems with file locking
Date: Mon, 28 Oct 2002 15:36:35 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.33.0210281500210.28850-100000@disney.cs.msstate.edu>
References: <E186Gxa-0003yb-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from walt.cs.msstate.edu ([130.18.208.30] helo=CS.MsState.Edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186HYu-00049e-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 13:36:40 -0800
Received: from disney.cs.msstate.edu (disney.cs.msstate.edu [130.18.208.197]);
          by CS.MsState.Edu (8.10.2+Sun/8.9.3/MsState-CS/evision: 1.3 $) with ESMTP;
          id g9SLaXM04053 for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 15:36:33 -0600 (CST)
Received: from localhost (kums@localhost)
	by disney.cs.msstate.edu (8.10.2+Sun/8.10.2) with ESMTP id g9SLaZU06721
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 15:36:35 -0600 (CST)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <E186Gxa-0003yb-00@usw-sf-list2.sourceforge.net>
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


Hi,

   When I try to do file locking using fcntl() on a file mounted via
NFSv3, I get error with errno set to 13 (EACCESS). This is on Linux
machines. The following gives a snapshot of /proc/mounts

disney.cs.msstate.edu:/export/home/kums /home/kums nfs
rw,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,
udp,noac,lock,addr=disney.cs.msstate.edu 0 0

  Any deamons missing from the following:

bash-2.05$ ps -ael | grep rpc
140 S    29   711     1  0  69   0    -   400 do_sel ?        00:00:00  rpc.statd
040 S     0   891     1  0  69   0    -     0 end    ?        00:00:00  rpciod
bash-2.05$ ps -ael | grep lockd
040 S     0   892     1  0  69   0    -     0 end    ?        00:00:00 lockd

  Please let me know the reason and the necessary procedures to be
done to fix this issue.

Sincere Regards,
-Kums

-- Kumaran Rajaram, Mississippi State University --
kums@cs.msstate.edu  <http://www.cs.msstate.edu/~kums>






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
