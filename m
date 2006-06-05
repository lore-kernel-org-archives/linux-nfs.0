From: Neil Brown <neilb@suse.de>
Subject: nfs-utils development now managed by 'git'.
Date: Mon, 5 Jun 2006 15:50:12 +1000
Message-ID: <17539.50708.563510.322443@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fn7z8-00045f-KZ
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 22:50:42 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fn7z8-0004sl-Fc
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 22:50:42 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fn7z7-0008K1-2L
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 22:50:42 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 1DB211EBF0
	for <nfs@lists.sourceforge.net>; Mon,  5 Jun 2006 07:50:35 +0200 (CEST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


As I mentioned by-the-way in another mail item, I am now using 'git'
rather than CVS for nfs-utils.

You can browse the current source at
   http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=summary

and download with

    git clone git://linux-nfs.org/nfs-utils

tar-balls of releases will still appear on sourceforge, but
development will not appear in the sourceforge CVS.

(I guess this should go on the http://nfs.sf.net/ page....)

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
