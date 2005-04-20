From: Annette Bitz <bitz@human-solutions.com>
Subject: nfsserver (Suse Linux 9.2) has problems with unix-clients
Date: Wed, 20 Apr 2005 10:06:07 +0200
Message-ID: <200504201006.07814.bitz@human-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOADq-0000Tf-Bf
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 01:06:10 -0700
Received: from www.human-solutions.com ([194.55.1.65] helo=mail.human-solutions.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOADp-0004By-Q5
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 01:06:10 -0700
Received: from [192.168.98.1] (helo=superserver.humanmodeling.tecmath.de)
	by mail.human-solutions.com with esmtp (Exim 3.36 #5)
	id 1DOADn-0005D3-00
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 10:06:07 +0200
Received: from aldea.humanmodeling.tecmath.de ([192.168.98.39])
	by superserver.humanmodeling.tecmath.de with esmtp (Exim 4.42)
	id 1DOADn-0002IP-AF
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 10:06:07 +0200
To: nfs@lists.sourceforge.net
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

Hi!

I just installed a new server, one of it's roles being our nfsserver.

I installed an actual Suse 9.2 professional (from DVD) using the following 
things:
- Linux ... 2.6.8-24-smp #1 SMP Wed Oct 6 09:16:23 UTC 2004 i686 i686 i386 
GNU/Linux
	-> kernel-smp-2.6.8-24
	kernel-source-2.6.8-24
	kernel-smp-nongpl-2.6.8-24
- yast2-nfs-server-2.10.5-2
- nfs-server-2.2beta51-208
- yast2-nfs-client-2.10.5-2

The connection Linux server -> Linux client runs without any problem, but...
I also try to connect from some Unix boxes with different unices. There are:
- SunOS ... 5.8 Generic_108528-29 sun4u sparc SUNW,Sun-Blade-1000
- HP-UX ... B.11.11 U 9000/782 2011691852 unlimited-user license
- HP-UX ... B.11.00 A 9000/785 2009266684 two-user license
- IRIX64 ... 6.5 04091957 IP30
- AIX ... 2 5 0041192C4C00

All platforms make problems with the new server. I can mount the shares, but 
the performance is really poor. I get many nfs stale-file handles. 
On Sun (only there?) I have the problem, that when I touch a file/directory, I 
don't see it resp. the changes immediately.

I googled around, but I can't find anything. I only found somesthing like 
"Just watch out that NFS can make assumptions about inodes - particularly
the kernel-mode NFS daemon.", but I don't know what this means (but it sounds 
good ;-) ).

Please help me! 
And please send a copy of your answer directly to me, for I'm new to the list 
and I don't know, if I receive the mails yet.

Thanks in advance,
Annette


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
