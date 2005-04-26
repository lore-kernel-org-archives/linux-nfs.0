From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 GETATTR/ACCESS requests flooding the network since
	upgrading to 2.6
Date: Tue, 26 Apr 2005 12:49:04 -0400
Message-ID: <1114534144.13568.57.camel@lade.trondhjem.org>
References: <87r7h4gho4.fsf@amaterasu.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQTFP-0004T8-01
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 09:49:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQTFM-0003Eb-Ca
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 09:49:18 -0700
To: Nix <nix@esperi.org.uk>
In-Reply-To: <87r7h4gho4.fsf@amaterasu.srvr.nix>
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

to den 21.04.2005 Klokka 18:31 (+0100) skreiv Nix:
> I upgraded from 2.4.28 to 2.6.10 (and then .11) a month ago. In 2.6.11
> at least, and probably in 2.6.10 (alas, I didn't notice this behaviour
> early enough to be sure: I can reboot into 2.6.10 and see if it
> disappears if anyone wants), the Linux NFS client / kernel server
> combination has been absolutely *flooding* the network with ACCESS
> requests (and to a somewhat lesser extent GETATTR).

The following patch has already been applied to the 2.6.12-rc series.

http://client.linux-nfs.org/Linux-2.6.x/2.6.12-rc1/linux-2.6.12-00-fix_access.dif

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
