From: Neil Brown <neilb@suse.de>
Subject: RFC - remove rquotad from nfs-utils for 1.1.0.
Date: Mon, 7 May 2007 11:26:03 +1000
Message-ID: <17982.32811.860687.644860@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hkrzd-0001FG-U9
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 18:26:25 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hkrzg-0003rd-6K
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 18:26:28 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id C411D121FE
	for <nfs@lists.sourceforge.net>; Mon,  7 May 2007 03:26:25 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


It appears that both "nfs-utils" and "quota" have an implementation of
rquotad.

This is not a good thing as inevitably one will get maintained and the
other not.

It appears that the one in nfs-utils is not being maintained.  A quick
look shows that it ignores anything other than ext2 or ext3.  This
suggests that no one has seriously used it for quite a long time.

I am in favour of removing it from nfs-utils for 1.1.0.  I note that
neither SuSE or Debian use it (they both use the version from the
quota package) I suspect other distros do that same.

Can I get someone to second my nomination?

Thanks,

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
