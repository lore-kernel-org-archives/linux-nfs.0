From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: High Availability NFS Proposal
Date: Sun, 15 Sep 2002 20:12:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15748.23840.351420.134476@notabene.cse.unsw.edu.au>
References: <200208242216.g7OMG3802286@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qWOm-0001l1-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 03:13:04 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <James.Bottomley@steeleye.com>)
	(for <nfs@lists.sourceforge.net>) (for <lmb@suse.de>) By tone With
	Smtp ; Sun, 15 Sep 2002 20:12:54 +1000
To: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: message from James Bottomley on Saturday August 24
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

On Saturday August 24, James.Bottomley@steeleye.com wrote:
> 
> I'll proceed in two phases: mountd first to give a HA solution and statd next 
> to give the complete HA-NFS solution.  The hooks should be useable by any HA 
> clustering software on Linux.

Any progress on this?... The idea seems quite sound.
My only suggestion would be not to depend on the existance of a
program in /var/lib/nfs, but rather to have such a program specified
as a command line argument.  It makes it more explicit.

Also, the need for this support in mountd will almost certainly go
away in 2.6 (that is what I am working on at the moment) but ofcourse
2.4 is going to be around for a while so it is probably still worth
while.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
