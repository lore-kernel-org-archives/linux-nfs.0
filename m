From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: Re: [autofs] Server/client mismatch over status of a
	mount ...
Date: 19 Feb 2003 19:20:16 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1045711216.3155.5.camel@ixodes.goop.org>
References: <200302191358.h1JDwECX026719@buggy.badula.org>
	 <3E53C9EC.8080903@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ion Badulescu <ionut@badula.org>, nfs@lists.sourceforge.net,
	autofs@linux.kernel.org, trond.myklebust@fys.uio.no,
	james-p@moving-picture.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-206-170-148-147.dsl.snfc21.pacbell.net
	([206.170.148.147] helo=gw.goop.org ident=firewall)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lhG0-0003Sz-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 19:20:20 -0800
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <3E53C9EC.8080903@zytor.com>
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

On Wed, 2003-02-19 at 10:16, H. Peter Anvin wrote:
> Ion Badulescu wrote:
> > Isn't autofs v4 supposed to fix this? I remember Jeremy mentioning that
> > the filesystem would lock all accesses to a dentry scheduled to be 
> > unmounted until the daemon replied to the request.
> > 
> 
> That's fine and dandy, but you would have to atomically lock *all* 
> dentries belonging to the subtree, which I suspect (but don't know for 
> sure) is impossible.

I seem to have missed the rest of this thread.  What's the context?
        
        J



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
