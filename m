From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: patchs for lockd: granted_res_proc, client address check, blocking check
Date: Thu, 25 Apr 2002 15:59:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020425155951.E13292@zeus.centre-cired.fr>
References: <20020423103152.A3624@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170jrT-0000zb-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Apr 2002 07:04:40 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id QAA10008
          for <nfs@lists.sourceforge.net>; Thu, 25 Apr 2002 16:03:34 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3PDxpL15495
	for nfs@lists.sourceforge.net; Thu, 25 Apr 2002 15:59:51 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020423103152.A3624@zeus.centre-cired.fr>; from dumas@centre-cired.fr on Tue, Apr 23, 2002 at 10:31:52AM +0200
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

I follow up on my patchs, because there are some more issues.

First issue:

This is related with the patch implementing nlmsvc_proc_granted_res (if the 
patch isn't applied, the server never gets the status from the clients
in response to a granted_msg).

With the patch applied, the server get the client status. If the status is bad,
the lock is removed at the server side. I think it is the right thing (I didn't
do it, it is the granted_reply function behaviour; in the specification, I
didn't saw anything about what the server should do upon receiving a bad
status).

The client send a bad reply when it get a granted_msg with a lock it didn't
requested. I also think it is fine. However this leads to the following
problem:

suppose the server send a grant_msg with a lock. The client now has the lock
granted, it sends a granted_res with a good status. Now suppose the server
never receive this callback. The server will resend a grant_msg with the lock.
The client isn't waiting for a granted_res anymore and thus responds with a
granted_res with a bad status. If the server gets this granted_res it will
deallocate the lock. At that point there is no lockfrom the server point of
view and a lock from the client point of view.

Is it a problem ?

If yes I think that a possible solution would be that when a client gets a
granted_msg for a lock he thinks he didn't request, he looks at all the locks
on the system, and if he finds this one, he returns a good status. I think this
isn't a violation of the standard, because it is arguable that the procedure
didn't failed when the client has the lock allready granted (the code for this
is allready quasi existing because it is roughly the same than what happens
when the server just rebooted).

If it is needed, is it a acceptable solution ?


Second issue:

This is unrelated with the patch. 

In case of a client becoming unreachable at a bad time, it may happen that 
a granted lock is never released. Here is the scenario:

The client ask for a blocking lock and the server responds that the lock is
allready taken. After some time the client becomes unreachable (but doesn't 
crash and reboot, that case is handled by statd) for whatever reason. Then 
the lock becomes available, the server locks the file, and send a granted_msg. 
However, as the client is unreachable the server will keep on resending 
granted_msg (see nlmsvc_grant_blocked). This means that the file will never 
be lockable anymore.


I have a simple idea for a solution to this problem, however it raises other
issues. A possibility would be to have a timer (5 minutes, or so...) such 
that when it is exceeded, the server stops sending granted_msg and unlocks 
the lock (calls delete_block(...,1)). However, if the client is waiting for 
that lock and is blocking, it will block forever. It is not a problem in the
linux implementation, as the client does busy waiting. (if the server could 
send a status in the granted_msg call, it would have been easier, but I
cannot see such a thing).

What do you think about that ?

Pat


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
