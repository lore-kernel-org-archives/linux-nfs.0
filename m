From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs corrupts files
Date: Thu, 14 Oct 2004 19:26:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097774783.18925.10.camel@lade.trondhjem.org>
References: <416EA5F4.5090701@lenherr.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CI9NG-00070M-06
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 10:26:46 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CI9ND-0004lJ-Rz
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 10:26:45 -0700
To: Thomas Lenherr <thomas@lenherr.name>
In-Reply-To: <416EA5F4.5090701@lenherr.name>
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

P=E5 to , 14/10/2004 klokka 18:14, skreiv Thomas Lenherr:

> ok, here is what i did:
> i had some files on an nfs-server (v3) using kernel 2.6.8-gentoo-r8
> (updated because of the trouble). the 9 files had an average size of
> about 180mB and i built the md5sums of these files via ssh _on_ this
> server.
>=20
> after that i transferred these files to my workstation, once via nfs and
> once via smb and let them check with md5sum again. the files transferred
> with smb were ok, but 6 of the 9 files tranferred via nfs were corrupt.
> then i made cmp between the local files (transferred with nfs of course)
> and the files on the nfs-server. the result:
> 1) multiple use of cmp on files which md5sum mentioned as corrupt
> resulted in reporting differences at different positions
> 2) sometimes the usage of cmp on files which md5sum mentioned as correct
> resulted in reporting differences...

You don't mention which kernel the client was running. Was it the same
as the server?

Have you tried just grabbing a kernel 2.6.8.1 from ftp.kernel.org, and
compiling it up (using the same .config as the gentoo kernel if you
like) and then doing the same thing? I ask 'cos I just don't know what
is in the gentoo kernels.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
