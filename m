From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.statd port #, and other similar questions
Date: Thu, 5 Sep 2002 12:29:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15734.49517.134859.817217@notabene.cse.unsw.edu.au>
References: <001d01c25437$0f66b940$d281f6cc@WEASEL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mmON-00036Z-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Sep 2002 19:29:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <nw@codon.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Thu, 5 Sep 2002 12:29:02 +1000
To: "Steve Wolfe" <nw@codon.com>
In-Reply-To: message from Steve Wolfe on Wednesday September 4
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

On Wednesday September 4, nw@codon.com wrote:
> 
>   On a related note, is it possible to make the lock manager to also use a
> low-numbered port for firewalling purposes?

Kernel parameters: lockd.udpport=778 lockd.tcpport=778
Module parameters: nlm_udpport=778 nlm_tcpport=778

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
