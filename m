From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS][PATCH] Making sure negative lookup entries don't
	exist
Date: Fri, 28 Jan 2005 19:05:08 -0800
Message-ID: <1106967908.10024.19.camel@lade.trondhjem.org>
References: <41FA88D5.6010904@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cuivb-0002U7-J2
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:05:39 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cuivb-0005Xl-1a
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:05:39 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41FA88D5.6010904@RedHat.com>
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

fr den 28.01.2005 Klokka 13:47 (-0500) skreiv Steve Dickson:
> Here is a 2.4.28 patch that ensures negative cached dirents
> do not exist by always doing an otw getattr to the server.
> This does cause a small increase in getattrs (~3% from what
> I saw in my testing) but it seems to me the price is worth it to
> ensure the client does not lie about the existence of a file.

If you are going to do a GETATTR on each call, why cache negative
dentries in the first place? Better then to simply remove the relevant
lines in nfs_lookup() and replace all occurrences of d_delete() with
d_drop().

Note, though, that both patches will seriously kill performance on
static, frequently-accessed directories (think $PATH, /usr/share etc.),
so we're certainly not applying that kind of patch to the mainline
kernel...

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
