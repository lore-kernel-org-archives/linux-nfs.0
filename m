From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Stale file handle
Date: Tue, 4 Feb 2003 12:36:14 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15935.6414.797449.12870@notabene.cse.unsw.edu.au>
References: <200302031903.53937.chris-nfs@drspirograph.com>
	<200302041044.45333.chris-nfs@drspirograph.com>
	<shsznpcopqe.fsf@charged.uio.no>
	<200302041218.31527.chris-nfs@drspirograph.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fs1E-0006GI-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 17:37:00 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chris-nfs@drspirograph.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 4 Feb 2003 12:36:46 +1100
To: Chris Jensen <chris-nfs@drspirograph.com>
Cc: nfs@lists.sourceforge.net
In-Reply-To: message from Chris Jensen on Tuesday February 4
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

On Tuesday February 4, chris-nfs@drspirograph.com wrote:
> > What type of filesystem are you using on the server?
> 
> Ohy, yes that :) FAT32 (vfat module)

Sorry.  You lose.

kNFSd only begrudginly supports FAT, and only to a limited extent.  It
sometimes works, but don't depend on it.  Particularly don't depend on
it after a server restart.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
