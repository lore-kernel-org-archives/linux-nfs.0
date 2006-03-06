From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: ACL on NFS, how make it work?
Date: Mon, 6 Mar 2006 10:41:39 +0100
Message-ID: <200603061041.40841.agruen@suse.de>
References: <20060303103806.GB8038@sv.lnf.it> <20060303163535.GB32552@fieldses.org> <20060306090557.GD8429@sv.lnf.it>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGCDY-0005J4-N4
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 01:41:28 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FGCDX-0000rK-Fz
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 01:41:28 -0800
To: Marco Gaiarin <gaio@sv.lnf.it>
In-Reply-To: <20060306090557.GD8429@sv.lnf.it>
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

Hello,

everything you reported so far looks fine. What do these give you on the 
server and client?

  grep CONFIG_NFS_V3_ACL /proc/config.gz
  grep CONFIG_NFSD_V3_ACL /proc/config.gz

Can you set acls when mounting localhost:/srv locally on the server?

Andreas


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
