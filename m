From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 15:12:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085512326.9224.33.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0405251307290.24001-100000@fattire.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>, Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BShLP-000306-Ee
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:12:11 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BShLO-0000ZN-Br
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:12:10 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.44.0405251307290.24001-100000@fattire.ngdc.noaa.gov>
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

P=E5 ty , 25/05/2004 klokka 15:08, skreiv Ara.T.Howard:
> yes, in that it would work, you simply would not coordinate with other
> processes which do NOT use fcntl based locks.  ruby and perl ship with
> implemtations of flock which are, in fact, fctnl under the hood.

No it would not. Read the manpages...

Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
