From: Martin Spott <Martin.Spott@uni-duisburg.de>
Subject: Re: nfs over TCP stable?
Date: 6 May 2003 06:57:40 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <b97md4$iap$1@foehn.quickstep.oche.de>
References: <3EB44527.6090005@wanadoo.es>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sundancer.oche.de ([194.94.252.29])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19CwnJ-0004oL-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 00:23:22 -0700
Received: from foehn.quickstep.oche.de (localhost [127.0.0.1])
	by foehn.quickstep.oche.de (8.12.9/8.12.8) with ESMTP id h466vj0v020555
	for <nfs@lists.sourceforge.net>; Tue, 6 May 2003 08:57:46 +0200 (CEST)
Received: (from news@localhost)
	by foehn.quickstep.oche.de (8.12.9/8.12.8/Submit) id h466vfrQ020554
	for nfs@lists.sourceforge.net; Tue, 6 May 2003 08:57:41 +0200 (CEST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Xose Vazquez Perez <xose@wanadoo.es> wrote:

> Red Hat 9-kernel 2.4.20-9 doesn't include nfs over TCP because they
> said that "it doesn't work good enough in our testing....."

Linux as an NFS client against Solaris8 works excellent for me with NFS V.3
over TCP (over ATM  ;-)  - at least with stock 2.4.20 and 2.5.67 kernel.
Solaris as an NFS server even allows for 32 k read/write - which makes the
whole stuff pretty fast for large files,

Martin.
-- 
 Unix _IS_ user friendly - it's just selective about who its friends are !
--------------------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
