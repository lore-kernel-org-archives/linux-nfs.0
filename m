From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS][PATCH] Making sure negative lookup entries don't
	exist
Date: Sat, 29 Jan 2005 11:32:44 -0800
Message-ID: <1107027164.11814.9.camel@lade.trondhjem.org>
References: <41FA88D5.6010904@RedHat.com>
	 <1106967908.10024.19.camel@lade.trondhjem.org>
	 <41FB88C7.3060903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuyLG-0003Z1-LW
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 11:33:10 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuyLF-0000pj-Ig
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 11:33:10 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41FB88C7.3060903@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

lau den 29.01.2005 Klokka 07:59 (-0500) skreiv Steve Dickson:
> Trond Myklebust wrote:
> 
> >If you are going to do a GETATTR on each call, why cache negative
> >dentries in the first place? Better then to simply remove the relevant
> >lines in nfs_lookup() and replace all occurrences of d_delete() with
> >d_drop().
> >  
> >
> Well I believe that would cause an otw lookup which is much more expensive
> than a cheap getattr to ensure the correct mtime of the directory....

It is not that much more expensive (for Linux servers at least).

> >Note, though, that both patches will seriously kill performance on
> >static, frequently-accessed directories (think $PATH, /usr/share etc.),
> >  
> >
> Well in my testing, which consisted of running the cthon04 tests a 
> number of
> times and counting the opts with nfsstat, the getattrs only went up by 
> 3% and the
> lookups when down by about 2%.... which was a bit surprising....

I can believe it for Connectathon, but that doesn't really test the sort
of scenario I described where you are repeatedly searching through
read-only directories for frequently-used files.

Try looking at an nfsroot setup with and without your patch. That should
illustrate more clearly what I meant.

> >so we're certainly not applying that kind of patch to the mainline
> >kernel...
> >  
> >
> hmm... I hate when you say things like that... :-)  I just trying to 
> come up with

In this case it's a question of "been there, done that, had the Torvalds
chastise me for my stupidity"... 8-)

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
