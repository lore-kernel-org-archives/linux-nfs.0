From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 13:36:15 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0311281329360.22389-100000@kenzo.iwr.uni-heidelberg.de>
References: <200311281111.49153.jojo@automatix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APhrB-0000tl-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 04:36:22 -0800
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1APhrB-0004KI-Cp
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 04:36:21 -0800
To: Juergen Sauer <jojo@automatix.de>
In-Reply-To: <200311281111.49153.jojo@automatix.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 28 Nov 2003, Juergen Sauer wrote:

> Mathew McNally reported the same thing, problems with Nvidia Graphic disturbs
> NFS/Network.

I haven't seen this report, but you probably mean "disturbs Nvidia-based 
network" as probably in a combo with Nvidia chipset, NIC and graphics 
chip. I can tell that various computers that I take care of with Nvidia 
video cards (but no other Nvidia components) have no network problem when 
the _video_ Nvidia driver is used; the NICs used in these computers are 
3C905C, E1000 and SIS900something.

AFAIK, on the netdev mailing list there were some messages about a new 
open-source driver (forcedeth) for the Nvidia NICs. Try to look it up...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
