From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client side noac
Date: Fri, 25 Jun 2004 15:17:01 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088191021.4333.75.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
	 <1088186851.4333.65.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdwC7-0001bf-9J
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 12:17:03 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BdwC6-00012Y-SG
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 12:17:02 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
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

P=E5 fr , 25/06/2004 klokka 14:59, skreiv Ara.T.Howard:

> what i mean is, suprising things can raise ESTALE (i'm using an exception
> based language that maps errno to exceptions - ruby)

If the server is acting sanely, the only thing that can cause an ESTALE
to occur is if a file gets deleted from some process on another client.
Unless you are playing really silly games (allowing other clients to
delete *open* files from underneath you), you should usually be able to
get round that problem by turning off attribute caching on the parent
directories: acdirmin=3Dacdirmax=3D0.

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
