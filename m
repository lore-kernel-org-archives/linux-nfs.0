From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: silly names
Date: Fri, 03 Sep 2004 15:19:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094239187.8196.70.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0409031131070.7569@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3JbD-0006df-9H
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 12:19:51 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C3JbB-0003JJ-Ns
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 12:19:51 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0409031131070.7569@harp.ngdc.noaa.gov>
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

P=E5 fr , 03/09/2004 klokka 13:35, skreiv Ara.T.Howard:
> are there causes other than some remote client removing an open file for
> sillynames appearing in a directory containing a file shared (via locking=
) by
> many clients?  i have a directory containing such a file where many silly=
names
> appear, but eventually disappear.  none of the files in the directory are=
 ever
> being removed - so what could cause this?  the code is working fine - i'm=
 just
> wondering about the causes of this...

 -  A client crash
 -  Someone renaming a sillyrenamed file on the server

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
