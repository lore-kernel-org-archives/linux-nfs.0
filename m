From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: combined ac/noac mounts
Date: Thu, 02 Sep 2004 20:40:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094172012.26067.21.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0409021822160.1684@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C327r-00081W-Aa
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:40:23 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C327p-0000sx-Hu
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:40:23 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0409021822160.1684@harp.ngdc.noaa.gov>
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

P=E5 to , 02/09/2004 klokka 20:25, skreiv Ara.T.Howard:
> if one exports a file system and also does a sub-export of that file syst=
em
> from a server and a client has two mounts to that system: one noac and on=
e
> 'ac' - will accesses to files via the various paths do the 'right thing'.=
  eg.
> accesses via the noac path will hit the server while accesses via the 'ac=
'
> mount will try to use the cache?

No. "noac" is *NOT* the same thing as directIO.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
