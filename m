From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Linux' NFS locking b0rken?
Date: Fri, 28 May 2004 07:28:26 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405280726210.2463-100000@fattire.ngdc.noaa.gov>
References: <1085675509.4074.26.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, Dan Stromberg <strombrg@dcs.nac.uci.edu>,
   Jeffrey Layton <jtlayton@poochiereds.net>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BThPl-0001V9-3Z
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 06:28:49 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BThPk-00014x-QW
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 06:28:48 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085675509.4074.26.camel@lade.trondhjem.org>
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

On Thu, 27 May 2004, Trond Myklebust wrote:

> That said, I believe that RHEL-3 at least is returning an error these days
> whenever you try to flock over NFS

yes it does:

  ~/shared > cat /etc/redhat-release 
  Red Hat Enterprise Linux WS release 3 (Taroon Update 2)

  ~/shared > uname -srm
  Linux 2.4.21-15.ELsmp i686

  ~/shared > ruby -e 'open("nfs","w").flock File::LOCK_EX'
  -e:1:in `flock': No locks available - nfs (Errno::ENOLCK)
          from -e:1


cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| "640K ought to be enough for anybody." - Bill Gates, 1981
===============================================================================



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
