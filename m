From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 18:11:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085523068.12612.58.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>, Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSk8l-00082Y-7U
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 15:11:19 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BSk8k-00059U-Kr
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 15:11:18 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
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

P=E5 ty , 25/05/2004 klokka 17:09, skreiv Ara.T.Howard:
> i'm not saying this is GOOD - just that you certainly can make a wrapper
> around fcntl and call it flock (or anything else for that matter) and so =
long
> as all your processes are using this interface all will be well.  of cour=
se
> the two types don't mix.  in any case i understand what you are saying,
> nevertheless it __is__ being done out there:

That's like saying you can paint the word "aeroplane" on a bicycle then
launch it off a cliff. Sure, you can, but that doesn't mean a passenger
won't notice the subtle differences...

http://www.freebsd.org/cgi/man.cgi?query=3Dflock&sektion=3D2&apropos=3D0&ma=
npath=3DFreeBSD+5.2-RELEASE+and+Ports
defines precisely what is expected of a lock that was set by flock().

Any program which relies on the fact that BSD locks are inherited by
child processes will fail to work correctly with you wrapper (because
fcntl() locks are not inherited).

...and indeed the people who wrote it *do* acknowledge in their comments
that "The calls might not be completely interchangeable".

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
