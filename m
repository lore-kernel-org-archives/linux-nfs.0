From: Markus Korth <markus.korth@zn-ag.com>
Subject: Re: export only to special mac addresses
Date: Mon, 25 Mar 2002 09:37:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C9EE1DF.458421EB@zn-ag.com>
References: <200203211807.g2LI74M02426@fubini.pci.uni-heidelberg.de> <20020323161512.GA10804@obelix.home.gunix.de> <200203240125.54414.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from berlin.zn.ruhr-uni-bochum.de ([134.147.254.1] helo=mailserver.zn-ag.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pPvN-0005mX-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 00:33:53 -0800
Received: from zn-ag.com (london [134.147.254.11])
	by mailserver.zn-ag.com (Postfix on SuSE Linux eMail Server 3.0) with ESMTP id 058207C72
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 09:31:31 +0100 (CET)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Bernd Schubert schrieb:

> > To slightly increase security we would like to allow only clients with
> > special MAC addresses to mount this fs.
> > So I'd like to know if there is already support for this.
>
> i dont know, if therfor is support from nfs directly.
> but i think, there is a arp filter module in upcominf 2.4.19
> linux-kernel.
>
> in combination with this i think it must be
> possible to realize a nfs export to spezial mac adresses.
>
> i dont tried it, because kernel is not stable yet, but ir will be in
> near future.

'iptables', the current filter system on Linux, has the ability to match
by MAC source adresse - this should 
also work on kernels below 2.4.19 !

Ciao
 Markus

-- 
---------------------------------------------- 
Senior Executive - Systemadministration

Direct Phone: + 49 / 234 9787-57
Direct Fax: +49 / 234 9787-77

ZN Vision Technologies AG
Universitaetsstrasse 160
44801 Bochum
Germany
http://www.zn-ag.com
----------------------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
