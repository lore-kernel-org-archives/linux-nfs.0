From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: More user reports: '{Random,Consistent} mount refusals'
Date: Mon, 16 Sep 2002 08:40:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15749.3142.18881.819668@notabene.cse.unsw.edu.au>
References: <20020915220953.GD11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qi3w-0003nF-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:40:20 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Mon, 16 Sep 2002 08:40:11 +1000
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
> I really don't know what to make of Debian bugs 81428 and 131811:
> 
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=81428&repeatmerged=yes
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=131811&repeatmerged=yes
> 
> Here is the most recent message from 81428.  Please help me figure out
> what's going on here ... I'm mostly packaging and mostly not coding in
> NFS land, and these reports are awfully confusing.

81428 is the "you cannot export a directory and an ancestor of that
directory both in the same filesystem" problem.  In this case,
/datadisk.

 From the /etc/exports mentioned in the first email:
# Linux devices
/datadisk              *.pangalhq.paul.de(rw,no_root_squash,no_subtree_check)
/datadisk/src          *.pangalhq.paul.de(rw,no_root_squash,no_subtree_check)
/datadisk/old_stuff/    *.pangalhq.paul.de(ro)
/datadisk/projects      labor(rw) idefix(rw,no_root_squash)

so all for /datadisk is rw, but all of /datadisk/old_stuff is ro.
This is impossible.
If the second and third of these four lines are removed it should
work.

This restriction is gone in 2.5.latest.  I'll probably modify the
user-space tools to do the check instead and to give better error
messages.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
