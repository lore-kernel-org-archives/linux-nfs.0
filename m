From: <trond.myklebust@fys.uio.no>
Subject: Re: Problems writing large files using 2.6 client
Date: Wed, 14 Jan 2004 23:22:00 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32895.141.211.133.197.1074118920.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AgtOo-00034A-Va
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 14:22:06 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AgtOo-0006AS-Iv
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 14:22:06 -0800
To: <sdmarcotte@comcast.net>
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

På on , 14/01/2004 klokka 15:38, skreiv Steven Marcotte:
> The following command errors out every time, the number of records
> written varies slightly.
>
>   dd if=/dev/zero  of=/mnt/backup/test bs=1024 count=6M
>   dd: writing `/mnt/backup/test': Invalid argument
>   4376337+0 records in
>   4376336+0 records out

I am unable to reproduce on my setup using a client with a 2.6.1-rc3
kernel. I get

dd if=/dev/zero  of=gnurr bs=1024 count=6M
6291456+0 records in
6291456+0 records out

and the resulting file is indeed 6Gb long.

Cheers,
  Trond





-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
