From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: Re: [autofs] Server/client mismatch over status of a
	mount ...
Date: 19 Feb 2003 19:43:35 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1045712615.3158.12.camel@ixodes.goop.org>
References: <Pine.LNX.4.44.0302192222470.27483-100000@moisil.badula.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "H. Peter Anvin" <hpa@zytor.com>, nfs@lists.sourceforge.net,
	autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-206-170-148-147.dsl.snfc21.pacbell.net
	([206.170.148.147] helo=gw.goop.org ident=firewall)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lhcu-0008Hq-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 19:44:04 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0302192222470.27483-100000@moisil.badula.org>
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

On Wed, 2003-02-19 at 19:26, Ion Badulescu wrote:
> > On Wed, 2003-02-19 at 10:16, H. Peter Anvin wrote:
> > > Ion Badulescu wrote:
> > > > Isn't autofs v4 supposed to fix this? I remember Jeremy mentioning that
> > > > the filesystem would lock all accesses to a dentry scheduled to be 
> > > > unmounted until the daemon replied to the request.
> > > > 
> > > 
> > > That's fine and dandy, but you would have to atomically lock *all* 
> > > dentries belonging to the subtree, which I suspect (but don't know for 
> > > sure) is impossible.
> > 
> > I seem to have missed the rest of this thread.  What's the context?
> 
> HPA was saying that autofs checks if a filesystem is busy before trying to
> unmount it, but does not lock it, so that a remount request could come in
> while umount is still running.

Autofs4 addresses this in two ways.

For the actual busyness check, it holds the dcache lock while traversing
the dentries, so that shouldn't change during the check.  It also blocks
new name traversals while it is doing an expiry check, so once it has
decided a tree is not busy, and gets the daemon to do the umount, new
users are blocked until the umount is finished.  Once the umount is
done, the new users will trigger a new mount.

	J



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
