From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Tue, 9 Apr 2002 08:58:24 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15538.8336.385286.494555@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
	<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
	<3CAFEE3C.8020606@blue-labs.org>
	<15537.1257.212812.909225@notabene.cse.unsw.edu.au>
	<3CB189DE.1B3AE1CD@literaturhaus.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ui2x-0000p1-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 15:55:35 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <au@literaturhaus.at>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 9 Apr 2002 08:55:15 +1000
To: Andreas Unterluggauer <au@literaturhaus.at>
In-Reply-To: message from Andreas Unterluggauer on Monday April 8
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

On Monday April 8, au@literaturhaus.at wrote:
> > 
> > "Exporting" a filesystem means doing two things:
> >  1/ telling mountd that it is allow to respond positively to mount
> >      requests.
> >  2/ telling the kernel nfsd that it is allow to respond to access
> >      requests.
> > 
> > When mountd responds to a mount request, it also tells the kernel to
> > respond to access requests.
> > But after a reboot, you need to run exportfs.  It reads
> > /var/lib/nfs/rmtab to find out which clients have which filesystems
> > mounted, and it tells the kernel to allow those clients to access
> > those filesystem.
> 
> Is it sufficent, if exportfs -r is run before rpc.nfsd are started
> instead of exportfs -a?
> The startscripts of redhat 6.2 uses exportfs -r (and we sometimes have
> troubles with stale mounts).

Yep, "exportfs -r" is fine.

 exportfs -r
    preserves any changes you may have made with 
      exportfs -o what,ever host:/path/to/export
whereas
 exportfs -a
    discards any such changes and just apply what /etc/exports 
    says.

Which one you want really depends on your sysadmin practices.  I
personally like "-a" because it means I know that after a reboot the
machine will come back to a known-correct state.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Sponsored by http://www.ThinkGeek.com/
