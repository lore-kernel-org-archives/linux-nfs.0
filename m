From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: [PATCH] lockd: client maintain a list of the locks held
Date: Fri, 24 May 2002 18:15:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020524181545.D15523@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BHkB-0006Il-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 09:16:44 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id SAA18352
          for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 18:15:22 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g4OGFjP16370
	for nfs@lists.sourceforge.net; Fri, 24 May 2002 18:15:45 +0200
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

This patch sets up a list of locks held by a client (associated with a host).
Then, when the client gets a granted lock it can respond positively if he 
holds allready the lock. This fixes a bug I described previously.

Some remarks:

- the locks are added and deleted based on the callbacks invoked from the file
locking systems when a lock is inserted or removed
(nlmclnt_insert_lock_callback...)

- a semaphore protects the list. I don't know if it is usefull, nor harmfull
(may it deadlock ?), but I set it up such that I don't have to bother with
simultaneous access.

- I use the linux lists.h. It is not needed to have doubly linked lists, but I
thought I would introduce less bugs than if I did my own.

- I did these lists because posix_test_lock wasn't really fine to detect that
the lock was allready held. However, I really decided to do it when I saw:
* FIXME: In 2.5 we don't want to iterate through any global file_lock_list.
*        Maintain NLM lock reclaiming lists in the nlm_host instead.
I think this patch implements such a list. Has anybody implemented the same
thing ? 
I haven't done the changes to the code actually doing the reclaiming, because 
I can't test crashing (I test everything on a single host). I could do the 
code, but can't test. Interested ?

Pat

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
