From: "Rongsheng Fang" <rsfang@hotmail.com>
Subject: no_root_squash made CPU  in heavy load on RH 7.3 NFS server
Date: Tue, 30 Jul 2002 22:07:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F90oN5gfUw3ZPpAATnL0002169b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f90.law12.hotmail.com ([64.4.19.90] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZiuG-0007o5-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Jul 2002 19:08:08 -0700
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

Hello NFS,

I found that the CPU stayed in very high load when I set up a NFS
server on a RH 7.3 with the following options:

/etc/exports:

/usr/local/share           10.0.2.0/255.255.255.0 (rw,no_root_squash)

The CPU load of nfsd from `top` was always between 5-10.

While I change the option to (rw,root_squash), the CPU load decreased
dramatically to 0.1-0.5.

Actually this NFS server only serves 4 Linux clients,  so the scaring
CPU load made me very confused.

Here are the basic information:

server ~% uname -a
Linux server 2.4.18-5 #1 Mon Jun 10 15:38:12 EDT 2002 i686 unknown

server ~% cat /etc/redhat-release
Red Hat Linux release 7.3 (Valhalla)

Any idea why?

BTW, I'm not in this list. If you've any idea on this, could you
please CC to me when you reply?

Thanks,
Rowsen


_________________________________________________________________
MSN Photos is the easiest way to share and print your photos: 
http://photos.msn.com/support/worldwide.aspx



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
