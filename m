From: Paul Jakma <paul@clubi.ie>
Subject: Re: NFSv4 daemons...
Date: Fri, 23 Jan 2004 14:54:36 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0401231453070.2140@fogarty.jakma.org>
References: <1073608448.1380.22.camel@nidelv.trondhjem.org>
 <1073619719.12271.7.camel@binkley> <1073621173.1398.55.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: seth vidal <skvidal@phy.duke.edu>, hjl@users.sourceforge.net,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak2i3-0001Va-Di
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 06:54:59 -0800
Received: from hibernia.jakma.org ([213.79.33.168])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Ak2i1-00051c-N6
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 06:54:58 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1073621173.1398.55.camel@nidelv.trondhjem.org>
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

On Thu, 8 Jan 2004, Trond Myklebust wrote:

> rpc.gssd is necessary if you want to use strong authentication (for
> NFSv2/v3 as well as for NFSv4).

Does this implement data stream encryption? (rpcsec as opposed to rpc
auth? (possibly getting my jargon wrong here))

> Cheers,
>   Trond

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
To thine own self be true.  (If not that, at least make some money.)


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
