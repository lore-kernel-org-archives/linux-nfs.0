From: pof <pau@eslack.org>
Subject: nsm_mon_unmon: rpc failed, status=-13
Date: Wed, 7 May 2003 03:34:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030507033420.36115319.pau@eslack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 217-126-5-53.uc.nombres.ttd.es ([217.126.5.53] helo=s0.pofhq.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DDpM-0006xR-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 18:34:37 -0700
Received: from w0.pofhq.net (w0.pofhq.net [192.168.1.10])
	(authenticated bits=0)
	by pof.eslack.org with id h471YKg4009700
	for <nfs@lists.sourceforge.net>; Wed, 7 May 2003 03:34:20 +0200
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

I am having problems with nfs locking, this is the error that I see in
my logs, and I don't know what it means:

nsm_mon_unmon: rpc failed, status=-13
lockd: cannot monitor 192.168.1.1
lockd: failed to monitor 192.168.1.1
nfs: server 192.168.1.1 not responding, still trying
nfs: server 192.168.1.1 OK
nsm_mon_unmon: rpc failed, status=-13
lockd: cannot monitor 192.168.1.1
lockd: failed to monitor 192.168.1.1
nsm_mon_unmon: rpc failed, status=-13
[...]

I am using nfs-utils 1.0.3 and NFSv3 over UDP.

Anyone knows what is causing this problem or how can I solve this?

Thanks in advance.

	pau.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
