From: Daniel Freedman <freedman@physics.cornell.edu>
Subject: Re: NFS problems across reboot
Date: Sun, 7 Apr 2002 01:39:53 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020407063953.GA30304@physics.cornell.edu>
References: <3CACA93C.5010304@blue-labs.org> <3CAD6A78.4205CD61@moving-picture.com> <3CAFCE8C.5030300@blue-labs.org> <15535.55222.401084.736426@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from gw.physics.cornell.edu ([128.253.60.142] helo=fs.physics.cornell.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u6LI-0003MM-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 22:40:00 -0800
Received: from ac.physics.cornell.edu (ac.physics.cornell.edu [192.168.0.3])
	by fs.physics.cornell.edu (Postfix) with ESMTP id B84FA16FF0
	for <nfs@lists.sourceforge.net>; Sun,  7 Apr 2002 01:39:53 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <15535.55222.401084.736426@notabene.cse.unsw.edu.au>
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

On Sun, Apr 07, 2002, Neil Brown wrote:
> Show us the relevent /etc/init.d file.
> My guess is that "exportfs -a" is being run *After* rpc.nfsd.
> It must must run *before* for correct operation.
> 
> NeilBrown

Hi,

I just checked the default NFS server init script from Debian stable (2.2)
as found in '/etc/init.d/nfs-kernel-server'.  It appears to violate the
above order, by starting exportfs *after* rpc.nfsd.  Am I missing something,
please?

****  Snippet from script listed below:

case "$1" in
  start)
          if grep -q '^/' /etc/exports; then
                   printf "Starting $DESC:"
		   printf " nfsd"
		   start-stop-daemon --start --quiet \
                        --exec $PREFIX/sbin/rpc.nfsd -- $RPCNFSDCOUNT
		   printf " mountd"
		   start-stop-daemon --start --quiet \
                        --exec $PREFIX/sbin/rpc.mountd -- $RPCMOUNTDOPTS
		   echo "."

		   printf "Exporting directories for $DESC..."
                   $PREFIX/sbin/exportfs -r
		   echo "done."
	  else
		   echo "Not starting $DESC: No exports."
          fi
	  ;;
		
		

Upon further inspection, I'm probably not missing something, since when I
checked a Debian woody (3.0) NFS server I'm also maintaining, it has
'exportfs' before the 'rpc.nfsd' call, as you taught me above (I'm grateful
to have learned more on this).  I'm a little surprised this fix wasn't
backported to Debian potato (even though they are understandably cautious to
introduce non-security related changes)...  I guess I'll have to change it
myself in the initscript while still using the potato box.

Could this explain why I've seen the same behaviour as described in an
earlier post in this thread: in other words, when the NFS server cleanly
reboots, all clients with open file handles develop difficulty with NFS
access (sorry I can't remember exact error, it hasn't happened in months);
come to think of it, though, I don't have this problem with my Debian woody
NFS server, which has the correct 'exportfs'/'rpc.nfsd' order in the
init-scripts.

Thanks so much, and take care,
Daniel

-- 
Daniel A. Freedman
Laboratory for Atomic and Solid State Physics
Department of Physics
Cornell University

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
