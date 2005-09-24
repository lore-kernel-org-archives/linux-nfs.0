From: Reuti <reuti@staff.uni-marburg.de>
Subject: Re: /etc/exports and netmask option
Date: Sat, 24 Sep 2005 19:47:12 +0200
Message-ID: <20050924194712.2xekkbwquyog8cow@home.staff.uni-marburg.de>
References: <04e901c5bf54$11cc31c0$15c809c6@PCJOERI01>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EJE7O-0003Bg-IY
	for nfs@lists.sourceforge.net; Sat, 24 Sep 2005 10:47:22 -0700
Received: from vhrz24.hrz.uni-marburg.de ([137.248.1.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EJE7N-0006nd-4e
	for nfs@lists.sourceforge.net; Sat, 24 Sep 2005 10:47:22 -0700
Received: from localhost (vhrz78.HRZ.Uni-Marburg.DE [137.248.1.54])
	by vhrz24.hrz.uni-marburg.de (8.13.4/8.13.4/Debian-3) with ESMTP id j8OHlCNY030222
	for <nfs@lists.sourceforge.net>; Sat, 24 Sep 2005 19:47:12 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <04e901c5bf54$11cc31c0$15c809c6@PCJOERI01>
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

Hi,

Zitat von Joeri Belis <joeri.belis@nollekens.be>:

> My nfs was working perfect with following /etc/exports on the server
>
> /home/test/nfstest 198.9.200.227(rw,sync,no_root_squash)
>
> But after a powerloss and restart of the server it only works with the
> following
>
> /home/test/nfstest 198.9.200.227/24(rw,sync,no_root_squash)
>
> if i don't add the /24 netmask option i get this error
>
> exportfs: No host name given with
> /home/test/nfstest(rw,no_root_squash)
> (ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_
> locks,mapping=identity,anonuid=-2,anongid=-2),
> suggest
> *(ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure
> _locks,mapping=identity,anonuid=-2,anongid=-2)
> to avoid warning
>
> So my question is. Why do i suddenly need to add the netmask option. I am
> sure it
> was not there before. After the powerloss, I had to remove the mount on the
> client
> it was giving rubbish. any ideas?

what happens if you give the command:

$ exportfs -o rw,sync,no_root_squash 198.9.200.227:/home/test/nfstest

directly? Maybe you have to "resync" some of the NFS files because of 
the crash.
You can try to shutdown the NFS service and look into /var/lib/nfs and zap the
etab, rmtab and xtab (:>etab) before you restart it.

Cheers - Reuti



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
