From: "Slawomir Orlowski \(Cympak\)" <sorlowski@cympak.com>
Subject: Cannot start nfsd deamon (nfssvc func.not implemented) ?
Date: Thu, 11 Jul 2002 16:19:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <008101c22918$458fc880$4900a8c0@cympak.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.138.227.126] (helo=server.cympak.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SkQp-0001X5-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 13:20:55 -0700
Received: from slawek.cympak.com ([192.168.0.73] helo=Slawek)
	by server.cympak.com with smtp (Exim 3.13 #1)
	id 17SkP1-0005Iq-00
	for nfs@lists.sourceforge.net; Thu, 11 Jul 2002 16:19:03 -0400
To: <nfs@lists.sourceforge.net>
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

I have untared and compilled  nfs-utils-0.1.9.1.tar.gz on my server with
RedHat6.1 (2.2.16 kernel).

After launching as root:

root@server download]# /etc/rc.d/init.d/nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
Starting NFS daemon: nfssvc: Function not implemented
[FAILED]

Could somebody help me, what should I do to get nfs server working??????

Best regards
Slawomir Orlowski



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
