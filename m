From: Ryan Mak <ryanmak@ameritech.net>
Subject: Re: NFS client hangs...
Date: Mon, 13 Dec 2004 17:05:03 -0800 (PST)
Message-ID: <20041214010503.80556.qmail@web81508.mail.yahoo.com>
References: <1102985885.10838.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce17o-0008Hx-6S
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:05:12 -0800
Received: from web81508.mail.yahoo.com ([206.190.37.111])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1Ce17m-0004NB-4f
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 17:05:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102985885.10838.1.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

oops. the tcpdump was taken on the client.

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> må den 13.12.2004 Klokka 16:50 (-0800) skreiv Ryan
> Mak:
> > Hi.
> > 
> > I am currently experiencing a hanging problem when
> I
> > try to either 'ls' or 'vi' on a successfully
> mounted
> > directory. I am using redhat 8.0, kernel version
> > 2.4.20-28.8, nfs-utils version nfs-utils-1.0.1-2.
> > 
> > enclosed is a tcpdump which shows retries from the
> > client despite an immediate ACK from the server. 
> 
> Was that tcpdump taken on the server or the client?
> 
> Cheers,
>   Trond
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>
> 
> 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
