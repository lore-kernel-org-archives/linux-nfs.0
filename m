From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: fstab entry with mountprog=,nfsprog= and mount hanging
Date: Fri, 6 Sep 2002 18:13:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020906181313.I23802@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17nLl8-0000qX-00
	for <nfs@lists.sourceforge.net>; Fri, 06 Sep 2002 09:15:02 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA10533
          for <nfs@lists.sourceforge.net>; Fri, 6 Sep 2002 18:11:28 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g86GDEF32437
	for nfs@lists.sourceforge.net; Fri, 6 Sep 2002 18:13:14 +0200
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

I am using intensively mountprog= and nfsprog= options (because I tunnel nfs).
I have a redhat 7.3 kernel 2.4.18, mount-2.11n.

Suppose I have this entry in fstab
localhost:/fs /fs nfs rw,mountprog=201000,nfsprog=200005

I found that there are problems in 2 (unrelated ?) cases:

First case:
On localhost I start an nfs server which sets these 2 programs. rpcinfo -p 
gives something like:
    201000    3   udp   1024
    200003    3   udp   1024
I mount /fs, everything is fine. Now if I restart the nfs server on localhost
such that it uses another port
(rpcinfo -p gives something like:
    201000    3   udp   1025
    200003    3   udp   1025)
All operation on /fs now hangs. From my readings of mount code, mount just
give to the nfs client in kernel a filehandle corresponding with a port.
Thus the nfs client cannot rebind to the new port, because it doesn't know 
the rpc program.

And if the nfs server reopens the port 1024, then it goes fine again (and I 
guess that any program opening this port will receive the nfs packets).

I think this is known, and I assume that it isn't easy to fix, because it
would mean adding the program to the handle mount gives to the kernel, and
having the program as an argument everywhere.


The second problem is as follow:
suppose the nfs server only registered the mount program, such that rpcinfo -p
gives:
    201000    3   udp   1025
Then mount /fs hangs. I think that it isn't normal, as it should better
exit saying 200005 not registered. But what seems even more abnormal, is 
that if you register the nfsprog afterwards, it still hangs. Even kill -9
doesn't take it away from the process list.

Once both programs are registered new mount /fs work, though.

Pat


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
