From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: more SMP issues
Date: Thu, 28 Mar 2002 15:28:34 +1100 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15522.39922.629022.356680@notabene.cse.unsw.edu.au>
References: <200203261934.NAA25602@popmail.austin.ibm.com>
	<15521.13735.293466.799706@notabene.cse.unsw.edu.au>
	<200203271649.KAA37894@popmail.austin.ibm.com>
	<15522.38550.557032.473224@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qRUM-0003jq-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 20:26:14 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <habanero@us.ibm.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 28 Mar 2002 15:26:03 +1100
To: Andrew Theurer <habanero@us.ibm.com>
In-Reply-To: message from Neil Brown on Thursday March 28
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

On Thursday March 28, neilb@cse.unsw.edu.au wrote:
> 
> Maybe when you only have 2 nfsds, the dynamics are a bit different and
> one thread gets migrated and you then get dual processor performance.
> 
> Possibly we could put some scheduler call in just after the wake_up()
> in svcsock.c which says to go bother some other CPU???

Something that might be worth a try is is to change the "list_add"
int svc_serv_enqueue to "list_add_tail".

With list_add, it just uses as many threads as it needs and leaves the
others completely ideal (and so not poluting cache).
With list_add_tail, it will cycle through all the threads, and
that might cause enough turbulence to get all the processors working.

It's not the *right* solution, but it is probably worth a try.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
