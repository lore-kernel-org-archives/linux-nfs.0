From: Andreas Metzler <ametzler@downhill.at.eu.org>
Subject: Re: Cannot start nfsd deamon (nfssvc func.not implemented) ?
Date: Thu, 11 Jul 2002 21:30:57 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <agkteh$2j1$2@downhill.at.eu.org>
References: <008101c22918$458fc880$4900a8c0@cympak.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailbox.surfeu.at ([212.197.128.120] helo=surfeu.at)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SlXv-0002Bf-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 14:32:20 -0700
Received: from [194.152.120.209] (HELO downhill.univie.ac.at)
  by surfeu.at (CommuniGate Pro SMTP 3.5.9)
  with ESMTP id 26616756 for nfs@lists.sourceforge.net; Thu, 11 Jul 2002 23:32:14 +0200
Received: from news by downhill.univie.ac.at with local (Exim 3.35 #1 (Debian))
	id 17SlWb-0000hD-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 23:30:57 +0200
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

"Slawomir Orlowski \(Cympak\)" <sorlowski@cympak.com> wrote:
> I have untared and compilled  nfs-utils-0.1.9.1.tar.gz on my server with
> RedHat6.1 (2.2.16 kernel).

> After launching as root:

> root@server download]# /etc/rc.d/init.d/nfs start
> Starting NFS services:                                     [  OK  ]
> Starting NFS quotas:                                       [  OK  ]
> Starting NFS mountd:                                       [  OK  ]
> Starting NFS daemon: nfssvc: Function not implemented
> [FAILED]
[...]

Looks like your _kernel_ is missing NFS server functionality, try the
precompiled rpm from RedHat updates.
                  cu andreas


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
