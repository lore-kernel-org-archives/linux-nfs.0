From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Must statd be running before nfs client makes mounts?
Date: Mon, 16 Sep 2002 09:26:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15749.5917.443602.600792@notabene.cse.unsw.edu.au>
References: <20020915225226.GI11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qimh-000070-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 16:26:35 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Mon, 16 Sep 2002 09:26:27 +1000
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
> I've just noticed that Debian mounts NFS filesystems from /etc/fstab
> before statd starts.  Is this OK?  (And I wonder at how it's going to
> try to do NFS client mounts before bind is even started, but I guess
> that's a separate issue... :-))

I think this is OK.
As long as statd starts before any lock requests are made, there
certainly wont be any problems.  And I think all the state management
happens in the background with timeouts and re-trys so it shouldn't
matter too much anyway (though if a process gets a lock, and the
server restarts before the local statd starts, then you loose).

A related question is whether you should mount nfs directories before
the nfs server is started.

If you have two machines that each mount a filesystem off the other,
and they both do foreground mounts (the default) before the
nfs server starts, then they will deadlock on boot.

I *think* (not having thought through it exhaustively) you should:

  (start devices, raid, etc)
 1/ mount local filesystems
  (start network, bind, portmap)
 2/ start nfsd if appropriate
 3/ start statd
 4/ mount nfs filesystems


It is possible that you need to treat some filesystems like /usr
differently.  On a data-less client, you probably need to mount
/usr before starting some of the network stuff like
bind or portmap.  These would typically be mounted with nolocks
so there are no issues with starting statd later, and
there shouldn't be cross-mounting issues in this situations.
So maybe you need a
 
  1a/ mount /var and /usr if they are nfs.

You really want a generic way of distinguishing which mounts
are needed early... pity mount won't let you select on
"dump" or "pass" fields (will it).

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
