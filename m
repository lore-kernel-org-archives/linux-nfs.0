From: Ion Badulescu <ionut@badula.org>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount
 ...
Date: Wed, 19 Feb 2003 22:26:25 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302192222470.27483-100000@moisil.badula.org>
References: <1045711216.3155.5.camel@ixodes.goop.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "H. Peter Anvin" <hpa@zytor.com>, <nfs@lists.sourceforge.net>,
   <autofs@linux.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lhMG-00052F-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 19:26:49 -0800
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <1045711216.3155.5.camel@ixodes.goop.org>
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

On 19 Feb 2003, Jeremy Fitzhardinge wrote:

> On Wed, 2003-02-19 at 10:16, H. Peter Anvin wrote:
> > Ion Badulescu wrote:
> > > Isn't autofs v4 supposed to fix this? I remember Jeremy mentioning that
> > > the filesystem would lock all accesses to a dentry scheduled to be 
> > > unmounted until the daemon replied to the request.
> > > 
> > 
> > That's fine and dandy, but you would have to atomically lock *all* 
> > dentries belonging to the subtree, which I suspect (but don't know for 
> > sure) is impossible.
> 
> I seem to have missed the rest of this thread.  What's the context?

HPA was saying that autofs checks if a filesystem is busy before trying to
unmount it, but does not lock it, so that a remount request could come in
while umount is still running.

I replied with the above...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
