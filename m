From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS Daemon not compilable as module in 2.4.18
Date: Sun, 4 Aug 2002 15:17:31 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15692.47339.574196.575558@notabene.cse.unsw.edu.au>
References: <20020804011509.A9382@nettis.grimsta>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17bDlK-0007Og-00
	for <nfs@lists.sourceforge.net>; Sat, 03 Aug 2002 22:17:06 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <basic@chello.se>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Sun, 4 Aug 2002 15:16:53 +1000
To: Daniel Brahneborg <basic@chello.se>
In-Reply-To: message from Daniel Brahneborg on Sunday August 4
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

On Sunday August 4, basic@chello.se wrote:
> Hi,
> 
> The NFS server part in the Linux kernel version 2.4.18 isn't compilable
> as a module.  At "depmod" time, it complains about not finding
> nfsd_linkage.  I assume it is something simple, but I don't know enough
> about the module mechanics.
> 
> Thanks in advance,
> 
> /Basic

Half right.
To compile nfsd as a module, you have to compile the kernel with
  CONFIG_NFSD=m 
I.e. you need to tell the kernel that nfsd is going to be a module.
You cannot compile the kernel with
  CONFIG_NFSD=n
and then later just compile nfsd as a module and hope to load it.
That doesn't work and I suspect that is what you are experiencing.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
