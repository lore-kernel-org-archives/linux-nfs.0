From: Robert Schwebel <robert@schwebel.de>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Thu, 9 Dec 2004 17:56:22 +0100
Message-ID: <20041209165622.GY20794@pengutronix.de>
References: <16815.63554.437489.308079@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcRab-0004Um-3j
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 08:56:25 -0800
Received: from metis.pengutronix.de ([213.252.143.165])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcRaa-0008Sx-Dt
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 08:56:25 -0800
Received: from robert by metis.pengutronix.de with local (Exim 3.36 #1 (Debian))
	id 1CcRaY-0007YE-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Dec 2004 17:56:22 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <16815.63554.437489.308079@cse.unsw.edu.au>
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

On Fri, Dec 03, 2004 at 04:23:14PM +1100, Neil Brown wrote:
> I have made available a pre-release of nfs-utils 1.0.7.

Here is an update of our "fix autotools to make nfs-utils crosscompile"
patch: 

	http://www.pengutronix.de/software/nfs-utils/nfs-utils-1.0.7-pre1-ptx1.patch.gz

We could not test the NFSv4 stuff, kerberos and gss, but the other
things seem to work. The patch was cleaned up and doesn't touch the
distribution code any more. 

Signed-off-by: Marc Kleine-Budde <m.kleine-budde@pengutronix.de>
Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>
Signed-off-by: Benedikt Spranger <b.spranger@pengutronix.de>

Robert 
-- 
 Dipl.-Ing. Robert Schwebel | http://www.pengutronix.de
 Pengutronix - Linux Solutions for Science and Industry
   Handelsregister:  Amtsgericht Hildesheim, HRA 2686
     Hornemannstraﬂe 12,  31137 Hildesheim, Germany
    Phone: +49-5121-28619-0 |  Fax: +49-5121-28619-4


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
