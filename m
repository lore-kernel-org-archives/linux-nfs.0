From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: multi-hopping NFS - aka re-exporting mounted filesystems
Date: Wed, 22 Dec 2004 08:55:28 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412220854290.26697-100000@maggie.lkpg.cendio.se>
References: <BAY22-F53EF5EFCFF6A662D31E4CA3A30@phx.gbl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ch1LL-00053v-N9
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 23:55:35 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ch1LK-0005cn-VU
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 23:55:35 -0800
To: John Lumby <johnlumby@hotmail.com>
In-Reply-To: <BAY22-F53EF5EFCFF6A662D31E4CA3A30@phx.gbl>
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

> I would like to be able to export an NFS-mounted filesystem for multi-hop 
> mounting.    I.e.:
> 
> Does anyone have any suggestions for how to get this working, or can anyone 
> point me to where I could lay my hands on this --re-export source code?

Try unfs3: http://unfs3.sourceforge.net/. 

-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
