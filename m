From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Sun, 7 Apr 2002 15:23:02 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15535.55222.401084.736426@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    James Pearson <james-p@moving-picture.com>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u56C-0007wu-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 21:20:20 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <david+cert@blue-labs.org>) (for <nfs@lists.sourceforge.net>)
	(for <james-p@moving-picture.com>) By tone With Smtp ;
	Sun, 7 Apr 2002 15:20:05 +1000
To: David Ford <david+cert@blue-labs.org>
In-Reply-To: message from David Ford on Saturday April 6
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

On Saturday April 6, david+cert@blue-labs.org wrote:
> Well, I'm an all Linux shop here, here are a few points to consider, 
> Trond, please help us out.
> 
> a) All machines are Linux
> b) this is 100% repeatable
> c) this is entirely unacceptable, every user (/home is mounted) has to 
> log out of their machine in order to remount, daemons need shut down.
> 
> Here's the scoop:
> 
> a) Linux 2.4.18-pre6 on one nfs server, 2.4.19-pre6 on the other
> b) 2.4.18-pre7 through 2.4.19-pre6 on clients
> c) mount options are all like: defaults,rsize=8192,wsize=8192
> d) programs run/ning, portmap, kmountd, knfsd 5, lockd, and statd.
> e) no firewall rules, /etc/exports is setup using individual IPs since 
> the friggen system can't deal with ranges or hostnames properly, 
> "Hostname is the same as "hostname" in DNS land, it should be in NFS 
> land as well. exports is like: /path 1.2.3.4(rw,no_root_squash).
> f) hosts.allow is basically *:all
> 
> When the server reboots (cleanly), the clients get the following, from 
> rebooting to running:
> nfs: server james not responding, still trying
> nfs: server james not responding, still trying
> nfs: server james OK
> nfs: server james OK
> nfs_statfs: statfs error = 13
> nfs_statfs: statfs error = 13
> nfs_statfs: statfs error = 13

13 == EACCES.  Looks like the filesystem isn't exported.

Show us the relevent /etc/init.d file.
My guess is that "exportfs -a" is being run *After* rpc.nfsd.
It must must run *before* for correct operation.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
