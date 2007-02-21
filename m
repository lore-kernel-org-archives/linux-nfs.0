From: Jean-Denis Girard <jd.girard@sysnux.pf>
Subject: Re: Server not working since 2.6.20-rc
Date: Tue, 20 Feb 2007 14:36:57 -1000
Message-ID: <45DB9429.6090603@sysnux.pf>
References: <45DB8447.1060903@sysnux.pf> <1172014569.27441.182.camel@rcs004>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: csc@cadence.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJfUQ-0002oG-Dp
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:37:47 -0800
Received: from smtpq.mana.pf ([202.3.225.153] ident=mirapoint)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJfUQ-000677-PL
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 16:37:48 -0800
In-Reply-To: <1172014569.27441.182.camel@rcs004>
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

Chris Croswhite a =E9crit :
> what does rpcinfo -p <server> show as services?  In the log files on the
> nfs server, is there any error with the attempted nfs mount?

[jdg@tiare ~]$ sudo rpcinfo -p
Password:
    program no_version protocole  no_port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    912  rquotad
     100011    2   udp    912  rquotad
     100011    1   tcp    915  rquotad
     100011    2   tcp    915  rquotad
     100021    1   udp  32792  nlockmgr
     100021    3   udp  32792  nlockmgr
     100021    4   udp  32792  nlockmgr
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   tcp  40936  nlockmgr
     100021    3   tcp  40936  nlockmgr
     100021    4   tcp  40936  nlockmgr
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100005    1   udp    937  mountd
     100005    1   tcp    940  mountd
     100005    2   udp    937  mountd
     100005    2   tcp    940  mountd
     100005    3   udp    937  mountd
     100005    3   tcp    940  mountd
     100024    1   udp  32793  status
     100024    1   tcp  44580  status

I have exactly the same list running rpcinfo -p tiare from my portable.

There's nothing special in the logs, just:
Feb 20 14:35:04 tiare mountd[13481]: authenticated mount request from =

q30.sysnux.pf:776 for /home (/home)


Thanks,
-- =

Jean-Denis Girard

SysNux                  Syst=E8mes Linux en Polyn=E9sie fran=E7aise
http://www.sysnux.pf/   T=E9l: +689 483 527 / GSM: +689 797 527

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
