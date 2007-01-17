From: "Timothy S. Nelson" <wayland@smartchat.net.au>
Subject: exportfs hangs when LDAP is in hosts line in nsswitch.conf
Date: Wed, 17 Jan 2007 20:30:45 +1100 (EST)
Message-ID: <Pine.LNX.4.64.0701172028560.7061@taliesin.nelson.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H77vm-0003F9-O4
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 02:22:11 -0800
Received: from ipmail03.adl2.internode.on.net ([203.16.214.135])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H77vj-0005Uk-Hz
	for nfs@lists.sourceforge.net; Wed, 17 Jan 2007 02:22:08 -0800
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

 	Hi all.

 	I'm using a standard install of CentOS 4 (rpm -q tells me it's 
nfs-utils-1.0.6-70.EL4), and am trying to get /etc/nsswitch.conf to use LDAP. 
At the moment everything works, except that when I make the "hosts" line in 
nsswitch.conf say "files ldap dns", then exportfs hangs.

 	I've submitted a bug report at the link below, with an attached strace 
of exportfs.  If anyone has any bright ideas, let me know.

http://sourceforge.net/tracker/index.php?func=detail&aid=1636336&group_id=14&atid=100014

 	:)


---------------------------------------------------------------------
| Name: Tim Nelson                 | Because the Creator is,        |
| E-mail: wayland@smartchat.net.au | I am                           |
---------------------------------------------------------------------

----BEGIN GEEK CODE BLOCK----
Version 3.12
GCS d+++ s+: a- C++$ U+++$ P+++$ L+++ E- W+ N+ w--- V- 
PE(+) Y+>++ PGP->+++ R(+) !tv b++ DI++++ D G+ e++>++++ h! y-
-----END GEEK CODE BLOCK-----

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
