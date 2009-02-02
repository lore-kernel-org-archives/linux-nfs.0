From: Toralf =?iso-8859-15?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: [NFS] QA Notice: for net-fs/nfs-utils-1.1.3
Date: Mon, 2 Feb 2009 11:39:25 +0100
Message-ID: <200902021139.26340.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44170 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755852AbZBBKkX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2009 05:40:23 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LTwDx-00007N-J6
	for linux-nfs@vger.kernel.org; Mon, 02 Feb 2009 21:40:17 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I get this during installation under a stable Gentoo system:

 * QA Notice: Package has poor programming practices which may compile
 *            fine but exhibit random runtime failures.
 * mount_xdr.c:306: warning: dereferencing type-punned pointer will bre=
ak=20
strict-aliasing rules

 * Please do not file a Gentoo bug and instead report the above QA
 * issues directly to the upstream developers of this software.
 * Homepage: http://nfs.sourceforge.net/


--=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3


-----------------------------------------------------------------------=
-------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

