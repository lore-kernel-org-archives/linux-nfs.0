From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Mon, 8 Apr 2002 12:48:09 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15537.1257.212812.909225@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
	<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
	<3CAFEE3C.8020606@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    James Pearson <james-p@moving-picture.com>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uP9m-0007ll-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 19:45:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <david+cert@blue-labs.org>) (for <nfs@lists.sourceforge.net>)
	(for <james-p@moving-picture.com>) By tone With Smtp ;
	Mon, 8 Apr 2002 12:45:04 +1000
To: David Ford <david+cert@blue-labs.org>
In-Reply-To: message from David Ford on Sunday April 7
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

On Sunday April 7, david+cert@blue-labs.org wrote:
> That was the problem.  Everything mounts just fine normally.  When the 
> server reboots, the client loses access.  All the client has to do is 
> unmount and remount and everything is fine again.  If it were a matter 
> of what was exported, then the remount should fail, but it doesn't.  Why 
> does the client lose the access but with no action on the server part, 
> the client regains access?  (to whom know the answer, please don't let 
> this thread just die away, ambiguity like this doesn't do anyone any good)

"Exporting" a filesystem means doing two things:
 1/ telling mountd that it is allow to respond positively to mount
     requests. 
 2/ telling the kernel nfsd that it is allow to respond to access
     requests.

When mountd responds to a mount request, it also tells the kernel to
respond to access requests.
But after a reboot, you need to run exportfs.  It reads
/var/lib/nfs/rmtab to find out which clients have which filesystems
mounted, and it tells the kernel to allow those clients to access
those filesystem.

The manpage should probably be made a bit more clear on this.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
