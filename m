From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Sun, 7 Apr 2002 15:44:56 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15535.56536.237108.198660@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
	<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ford <david+cert@blue-labs.org>,
    nfs@lists.sourceforge.net,
    James Pearson <james-p@moving-picture.com>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u5RO-0002sZ-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 21:42:15 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <neilb@cse.unsw.edu.au>) (for <david+cert@blue-labs.org>)
	(for <nfs@lists.sourceforge.net>) (for <james-p@moving-picture.com>)
	By tone With Smtp ; Sun, 7 Apr 2002 15:42:01 +1000
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: message from Neil Brown on Sunday April 7
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

On Sunday April 7, neilb@cse.unsw.edu.au wrote:
> 
> 13 == EACCES.  Looks like the filesystem isn't exported.
> 
> Show us the relevent /etc/init.d file.
> My guess is that "exportfs -a" is being run *After* rpc.nfsd.
> It must must run *before* for correct operation.
> 

Actually, that would cause ESTALE, not EACCES.

EACCES seems to suggest an XFS problem.
Can you duplicate this without using XFS????

NeilBrown

> NeilBrown
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
