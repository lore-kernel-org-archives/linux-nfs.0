From: Jose Celestino <japc@co.sapo.pt>
Subject: Client tuning
Date: Wed, 11 Dec 2002 13:11:45 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021211131145.GA1000@co.sapo.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.sl.pt ([212.55.140.13] helo=sl.pt)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18M6gW-0008JH-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Dec 2002 05:13:56 -0800
Received: from unknown (HELO morgoth.sl.pt) ([172.28.229.169])
          (envelope-sender <japc@co.sapo.pt>)
          by mail.sl.pt (qmail-ldap-1.03) with SMTP
          for <nfs@lists.sourceforge.net>; 11 Dec 2002 13:13:47 -0000
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

Hello,

I need some help fine tuning some NFS clients.

The server is a blackbox (an EMC Celerra which we don't administer, we
can't touch it, we can only give some hints and pray) the clients are
Linux boxes with kernel >= 2.4.18.

This system will be used, exclusivelly, as a webmail system with maildir
format "mailboxes". That means lots (ithousands to millions) of small
iles (<=30Kb) and tons of accesses to that same files. Access will be
made via an IMAP server, a POP server and a SMTP server.

I have the option of choosing between NFSv2/v3 and TCP/UDP and the
freedom to fully configure/reconfigure the client boxes. Any thoughs on
what I might tweak and look for? Any experiences on this?

TIA.

-- 
Jose Celestino | http://xpto.org/~japc/files/japc-pgpkey.asc
----------------------------------------------------------------
"Don't summarize. Don't abbreviate. Don't interpret." -- djb


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
