From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more on silly names
Date: Sat, 04 Sep 2004 18:58:57 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094338737.13791.15.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3jUy-0007RJ-FF
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 15:59:08 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C3jUx-0005oM-7b
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 15:59:08 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
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

P=E5 lau , 04/09/2004 klokka 18:27, skreiv Ara.T.Howard:
> i think i've found the cause of the sillnames appearing in my directory:
> for transaction sqlite aquires a lock, writes changes first to a db-journ=
al
> file, then to the actual db, closes the journal, unlinks the journal, and
> releases the lock.  this sequence should not create a silly file, but see=
ms
> to do so:

I believe that the Berkeley database code uses mmap() to read/write the
data, in which case close() will not actually suffice to sync the data
to the server (unlike the case of ordinary file write).

If mmapped data needs to be committed to disk before the flushd/pdflush
daemon gets round to doing it, you need to explicitly call msync().

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
