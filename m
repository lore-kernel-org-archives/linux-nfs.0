From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Locking from Tru64
Date: Thu, 6 Feb 2003 13:00:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15937.49587.612392.118333@notabene.cse.unsw.edu.au>
References: <Pine.LNX.4.53.0302041525090.22528@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18gbLC-0007KF-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Feb 2003 18:00:38 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <jss@ast.cam.ac.uk>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 6 Feb 2003 13:00:30 +1100
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: message from Jeremy Sanders on Tuesday February 4
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

On Tuesday February 4, jss@ast.cam.ac.uk wrote:
> Hi,
> 
> I don't know whether anyone had any ideas about my last problem? That's
> the problem where the linux clients had to be rebooted when the linux
> server was.
> 
> I have got an additional problem which I don't understand. We're locking
> mail spools over NFS from a Tru64 5.1B client machine to Linux
> 2.4.18-17.7.x (RedHat) server. Using a simple C program which opens the
> file, does lockf (fd, F_LOCK, 1)) and then closes it after 10 seconds,
> some users are able to lock their mail spool (one seen, actually) and many
> users are unable!

Are you using the insecure_locks export option?  If not, does it help?

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
