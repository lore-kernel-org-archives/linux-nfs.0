From: Dumas Patrice <dumas@centre-cired.fr>
Subject: lockd tunneling and statd again
Date: Tue, 23 Apr 2002 11:23:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020423112348.B3624@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zwan-0002pb-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 02:28:09 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id LAA05564
          for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 11:27:20 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3N9NmD03971
	for nfs@lists.sourceforge.net; Tue, 23 Apr 2002 11:23:48 +0200
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

After looking at how the lockd client side is implemented, it seems to me that
lockd tunneling raises no real difficulty. Indeed, the client is busy waiting,
thus it doesn't really matter that the GRANTED/GRANTED_RES callback is lost.

However, with the rpc tunneling I use, if all the nfs mounts are mounted with
the same lockd rpc number, it isn't possible to make a difference between
hosts, thus tunneling is possible, but with only one server.

Will the the lockd client side be redesigned (in such a way that losing server
callbacks becomes an issue) ? 
If not, could it be possible to have a lockprog= in the mount arguments ? I
have some ideas on how to implement that on the lockd client side, and it
doesn't seems so hard to do, however I have no idea about the nfs/mount changes
it would require.


Now, on the statd side, it seems to me that it could be possible for the server
to monitor the host issuing the lock demand, by looking at the caller_name
field, instead of relaying on the source of the rpc request. It would involve
some code change in the host lookup part of lockd, but not so much, I think.
Another way to achieve the same goal would be to implement non monitored lockd
clients using the NM_LOCK and the FREE_ALL callbacks, but it is a bad solution
because it forbids blocking locks.

However, on the client side, I can't see any possibility for lockd to get the
real server to monitor. Of course, the rpc forwarder knows that, but there is
nothing which permits it to tell it to the lockd client. 

There could be a possibility, but it is out of the lockd scope: the forwarder
could do the monitoring and reclaim the locks. However it is quite bad, because
this would mean reimplementing a quasi complete lockd client in the forwarder
which would have to be aware of the accepted locks, and so on.

Any thought about that ?

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
