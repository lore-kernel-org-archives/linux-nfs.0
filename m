From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: More user reports: '{Random,Consistent} mount refusals'
Date: Mon, 16 Sep 2002 08:46:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15749.3539.51250.596868@notabene.cse.unsw.edu.au>
References: <20020915220953.GD11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qiC9-0004fP-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:48:49 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Mon, 16 Sep 2002 08:47:17 +1000
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

131811 is hard to diagnose as there is little hard info.  No
/etc/exports etc.

I do note that:
  server is running 2.3.18-pre4.  I don't have any coherent patch
  history for what was happen that long ago, but I wouldn't be
  surprised if a pre-release of a devel kernel was broken.

  error message was: ENOSYS
nfsservctl(0x1, 0xbfffcd08, 0)          = -1 ENOSYS (Function not implemented)
nfsservctl(0x7, 0xbfffd9b8, 0x8055f60)  = -1 ENOSYS (Function not implemented)

  which suggests that nfsd support wasn't compiled into the kernel.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
