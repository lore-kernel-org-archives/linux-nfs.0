From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: fsid syntax
Date: Thu, 8 Aug 2002 06:31:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15697.33669.398331.848444@notabene.cse.unsw.edu.au>
References: <200208071711.00712.bernd-schubert@web.de>
	<shsk7n2d70y.fsf@charged.uio.no>
	<200208071830.54734.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cXS3-0004m0-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 13:30:39 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <bernd-schubert@web.de>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Thu, 8 Aug 2002 06:30:21 +1000
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: message from Bernd Schubert on Wednesday August 7
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

On Wednesday August 7, bernd-schubert@web.de wrote:
> On Wednesday 07 August 2002 17:26, Trond Myklebust wrote:
> > The fsid is a number, not a device. In principle you can set it to any
> > number you like as long as you keep it consistent over reboots.
> >
> > One suggestion is to use the device major/minor number in the format
> > minor + (major * 256). (That's what nfsd uses by default for block
> > devices.)
> >
> > Cheers,
> >   Trond
> >
> >
> 
> Uh, good that I asked for this, so I was completely wrong.
> 
> Is there a way to get the current fsid (after a reboot on Friday the fsid will 
> change and I don't want to reboot our clients) ? Or is it simply the fsid of 
> e.g.  /dev/sdb, so that I can get it with statfs() ?
> 
> Thanks for your help,

Sorry, you cannot do that.  The filehandles created with fsid=foo are
different from any filehandle created without fsid=.

If you want to change the device on the server what you need to do is:

1/ well in advance, add an 'fsid=42'(*) export option. 
   Clients using old file handles will still work.  Clients that
   subsequently mount will get new-style file handles.
2/ At your convenience, remount the filesystem on all clients, either
   by umount/mount or reboot or whatever.
3/ When all, or enough, clients have remounted, you can safely change
   the device number without affecting clients.

(*)  I really don't think that basing the fsid on the device number is
at all sensible.  Afterall, that is what we are trying to avoid.
Just pick a number, any number.
1 for the first filesystem, 2 for the second.
Your age for the filesystem storing you home directory.
42 for the filesystem storing the Great Question of Life, The
Universe, and Everything.

NeilBrown


> 
> Bernd
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
