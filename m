From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client side noac
Date: Fri, 25 Jun 2004 14:07:31 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088186851.4333.65.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bdv6u-0006jh-0b
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 11:07:36 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Bdv6s-0006mu-9e
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 11:07:34 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
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

P=E5 fr , 25/06/2004 klokka 13:49, skreiv Ara.T.Howard:
> is there any way for user code to make nfs file handles behave as if they=
 were
> mounted noac?

I don't understand the question.

Filehandles are used as the unique identifier of a file. If a filehandle
changes, it is considered to belong to a different file. In consequence,
the only time you can revalidate a filehandle is at file lookup time.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
