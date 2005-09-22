From: "Joeri Belis" <joeri.belis@nollekens.be>
Subject: /etc/exports and netmask option
Date: Thu, 22 Sep 2005 11:00:24 +0200
Message-ID: <04e901c5bf54$11cc31c0$15c809c6@PCJOERI01>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIMvQ-0006jk-LA
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 01:59:28 -0700
Received: from [194.78.89.210] (helo=linuxnol2004.nollekens.be)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EIMvQ-000094-57
	for nfs@lists.sourceforge.net; Thu, 22 Sep 2005 01:59:28 -0700
To: <nfs@lists.sourceforge.net>
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

My nfs was working perfect with following /etc/exports on the server

/home/test/nfstest 198.9.200.227(rw,sync,no_root_squash)

But after a powerloss and restart of the server it only works with the
following

/home/test/nfstest 198.9.200.227/24(rw,sync,no_root_squash)

if i don't add the /24 netmask option i get this error

exportfs: No host name given with
/home/test/nfstest(rw,no_root_squash)
(ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_
locks,mapping=identity,anonuid=-2,anongid=-2),
suggest
*(ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure
_locks,mapping=identity,anonuid=-2,anongid=-2)
to avoid warning

So my question is. Why do i suddenly need to add the netmask option. I am
sure it
was not there before. After the powerloss, I had to remove the mount on the
client
it was giving rubbish. any ideas?



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
