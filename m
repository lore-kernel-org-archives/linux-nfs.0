From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.19+RPC_ALL hangs running dbench 2.0
Date: Mon, 14 Oct 2002 18:03:52 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSF.4.32L2.0210141800290.13608-100000@lenny.sfrn.dnai.com>
References: <Pine.BSF.4.32L2.0210141450280.12721-100000@lenny.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181G9Z-0000J0-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 18:05:45 -0700
Received: from sideshow-bob.sfrn.dnai.com (sideshow-bob.sfrn.dnai.com [208.59.199.20])
	by moe.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id g9F0x4l71844
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 17:59:04 -0700 (PDT)
Received: from lenny (lenny.sfrn.dnai.com [208.59.199.9])
	by sideshow-bob.sfrn.dnai.com (8.11.3/8.11.3) with ESMTP id g9F12tR01410
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 18:03:05 -0700 (PDT)
	(envelope-from andrewr@nam-shub.com)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.BSF.4.32L2.0210141450280.12721-100000@lenny.sfrn.dnai.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Further testing has revealed that the hang shows up if the only patch
applied to vanilla 2.4.19 is linux-2.4.19-01-fix_kmap1.dif, if this helps
narrow down the problem.


andrew



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
