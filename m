From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: SM_UNMON again -> kernel
Date: 11 Jul 2003 11:38:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr84x768e.fsf@charged.uio.no>
References: <20030711061615.GA1924@quasar.nro.au.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19auhH-0000Eb-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 03:00:18 -0700
Received: from pat.uio.no ([129.240.130.16]:61815)
	by externalmx.vasoftware.com with esmtp (Exim 4.20 #1 (Debian))
	id 19auQk-0000W6-SA
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 02:43:07 -0700
To: Lawrence Ong <lawrence.ong@netregistry.com.au>
In-Reply-To: <20030711061615.GA1924@quasar.nro.au.com>
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


Is /etc/hosts consistent? The kernel only sends MON/UNMON requests on
the loopback port, so this suggests that something is translating
127.0.0.1<->"mymachine" instead of to "localhost".

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
