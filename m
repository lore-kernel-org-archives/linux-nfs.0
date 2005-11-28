From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: how much CPU/RAM does NFS need?
Date: Mon, 28 Nov 2005 15:02:26 +0100
Message-ID: <200511281502.26418.vincent.roqueta@ext.bull.net>
References: <438B0A94.8090201@informatik.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EgjYI-0002wK-3l
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 06:00:18 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EgjYF-0003y5-Im
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 06:00:17 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 4729B1A08DE
	for <nfs@lists.sourceforge.net>; Mon, 28 Nov 2005 14:59:31 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 12485-07 for <nfs@lists.sourceforge.net>;
 Mon, 28 Nov 2005 14:59:29 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 98C571A08B9
	for <nfs@lists.sourceforge.net>; Mon, 28 Nov 2005 14:59:28 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <438B0A94.8090201@informatik.rwth-aachen.de>
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

Le Lundi 28 Novembre 2005 14:48, Peter Schneider-Kamp a =E9crit=A0:
> Hi,
>
> we are about to purchase a file server for a 3,2 TerraByte disk array
> which has 2 GBit/s fibre channel connections. The server will
> have a PCI-X 133MHz fibre channel controller and a PCI-X 133MHz fibre
> ethernet card.
>
> How much CPU do we need to serve approx. 1 GBit/s of NFS from the
> disk array to the network?
I don't know the answer, but I think it lacks some important parameters :

How many clients do you have?
What kind of load clients do?

Vincent


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
