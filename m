From: James Pearson <james-p@moving-picture.com>
Subject: Re: NFS problems across reboot
Date: Mon, 08 Apr 2002 14:42:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CB19E57.EB3F1441@moving-picture.com>
References: <3CACA93C.5010304@blue-labs.org>
		<3CAD6A78.4205CD61@moving-picture.com>
		<3CAFCE8C.5030300@blue-labs.org>
		<15535.55222.401084.736426@notabene.cse.unsw.edu.au> <15535.56536.237108.198660@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ford <david+cert@blue-labs.org>,
 	nfs@lists.sourceforge.net
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uZVG-0004aC-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 06:48:14 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

I'm using XFS on my root file system - I'm using a "stock" RedHat 7.1 or
7.2 initscripts - so exportfs -r is run before rpc.mountd and rpc.nfsd

I can reproduce my problem by resetting an NFS server just after
automounting one of its exported disks. When the server comes up, the
client reports 'Permission denied' on that mount point.

If I repeat the test, but wait a short while before resetting the
server, everything is OK on reboot - and rmtab contains an entry for the
client).

It looks like the update to /var/lib/nfs/rmtab of the clients mount
hasn't been sync'd to disk before the server is reset.

In fact I can simulate this on a running server and client by:

On the client, mount one of the server's exported file systems and cd to
it.
Runs 'ls', everything fine. Then:

On the server:

cd /var/lib/nfs
cp rmtab rmtab.save
cat /dev/null > rmtab
/etc/init.d/nfs stop
/etc/init.d/nfs start

Then on the client, attempt to 'ls' etc. gives 'Permission denied'

If I then copy back the saved rmtab file and restart nfs, file access on
the client is OK.

I've also put /var/lib/nfs on an ext2 file system, but that didn't make
any difference - it seems to be that fact that the 'crash' happens
before the file data has been flushed to disk.

The man page for rpc.mountd says the rmtab file is 'mostly ornamental',
however in this case, it seems to be a bit more important. ...

So, is it possible to have a client 'survive' a server crash even if its
entry in rmtab hasn't been flushed? i.e. somehow allow the client access
even if there is no entry for the client in rmtab?

Thanks

James Pearson

Neil Brown wrote:
> 
> On Sunday April 7, neilb@cse.unsw.edu.au wrote:
> >
> > 13 == EACCES.  Looks like the filesystem isn't exported.
> >
> > Show us the relevent /etc/init.d file.
> > My guess is that "exportfs -a" is being run *After* rpc.nfsd.
> > It must must run *before* for correct operation.
> >
> 
> Actually, that would cause ESTALE, not EACCES.
> 
> EACCES seems to suggest an XFS problem.
> Can you duplicate this without using XFS????
> 
> NeilBrown
> 
> > NeilBrown
> >
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
