From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: Pb of optimization for a Cluster under Gigabit
Date: Wed, 7 Apr 2004 13:40:47 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0404071339080.25211-100000@kenzo.iwr.uni-heidelberg.de>
References: <40737404.7000401@ece.gatech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBBQP-0000Jt-IE
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 04:40:57 -0700
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBBQP-0000FG-4I
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 04:40:57 -0700
To: Didier CONTIS <didier@ece.gatech.edu>
In-Reply-To: <40737404.7000401@ece.gatech.edu>
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

On Tue, 6 Apr 2004, Didier CONTIS wrote:

> Would anyone have any suggestions or recommendations ? Should
> I switch rsize / wsize to 1024 ?

If the network cards and switch allow it, you could try first using 
Jumbo (9k) Ethernet frames; in such a setup, the 8k NFS packets would 
most likely travel unfragmented between server and clients.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
