From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: userspace NFS daemon
Date: Mon, 6 Sep 2004 02:47:42 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409060210030.12696-100000@kenzo.iwr.uni-heidelberg.de>
References: <1094422226.8081.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Frank van Maarseveen <frankvm@xs4all.nl>,
        Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C47fo-0005FH-A7
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 17:47:56 -0700
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C47fm-0007dt-Cr
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 17:47:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094422226.8081.51.camel@lade.trondhjem.org>
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

On Sun, 5 Sep 2004, Trond Myklebust wrote:

> Wow. People would actually trust their root partition to unfsd? The mind
> boggles...

Err, you mean to say that root-NFS only appeared after knfsd ? And 
that knfsd was absolutely flawless since day 1 ? :-)

Cluster nodes have usually a small number of software packages 
installed. Most "core" packages (like core-utils, grep, gawk, etc.) 
don't need locking. As / doesn't see itself much writting (which 
happens usually in /var and /tmp, but those can be mounted 
separately), NFSv3 vs. NFSv2 doesn't make much difference either. So 
what's the problem with using unfsd in these conditions ?

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
