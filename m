From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Bug#148482: 'nfs-kernel-server reload' immediately stales all nfs handles
Date: Mon, 16 Sep 2002 09:02:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15749.4467.265708.717072@notabene.cse.unsw.edu.au>
References: <20020915221931.GE11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qiPK-0001rL-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 16:02:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Mon, 16 Sep 2002 09:02:17 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Sunday September 15
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sunday September 15, chip@pobox.com wrote:
> So is 'exportfs -r' *supposed* to stale all NFS handles?  If so, is this
> adequately documented?  adTHANKSvance

exportfs -r 
is very dependant on the contents of /var/lib/nfs/rmtab.
Any export that exportfs finds in /proc/fs/nfs/exports that cannot be
deduced from /var/lib/nfs/rmtab and /etc/exports will be removed.

We try to keep rmtab up-to-date correctly, but the MOUNT protocol
really isn't good enough to get it 100% right.

My guess is that for some reason, some of the clients were not listed
in rmtab, so their entries in /proc/fs/nfs/exports were removed.
I don't know what would have caused this.  It could have been an admin
error.  It could be that the automounter sends unmount messages at the
wrong time.

It is possible that 'nfs-kernel-server reload' should do "-a", not
"-r", but it isn't certain.

The most obvious difference between the two is shown by this example:
 
 I have some standard exports in /etc/exports and I run
    exportfs -a
 to enact them.
 I then want to do another export for some special, temporary purpose,
 so I
    exportfs -o no_root_squash,rw mydesktop:/usr/src

 Later I make some changes to /etc/exports and want to enact them.
 If I
     exportfs -a
 then it will enact those changes, and leave my temporary export in
 place.
 If I
     exportfs -r
 then it will enact those changes and remove my temporary export.

 Which is right?  In different situations you want different
 behaviour.
 Maybe:
     reload -> exportfs -a
     enforce -> exportfs -r

Locally, we have a policy (and machinery) that says that any temporary
change will probably be blown away over night, so it you want
something to be more permanent than that, to it 'properly'.  So for
us, a nightly "exportfs -r" would probably be appropriate... as long
as our automounters did the right thing...

Again, 2.6 should not have the same dependance of rmtab so in a couple
of years you shouldn't have to worry.

NeilBrown




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
