From: <nfsmailinglist@heessels.com>
Subject: RE: 'random' diskless clients hangs
Date: Sat, 6 Sep 2003 09:25:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NEBBIHNAFKJAFOHBHGCOCEJMEFAA.nfsmailinglist@heessels.com>
References: <shsn0djm2ut.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vXSL-0002A1-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Sep 2003 00:26:01 -0700
Received: from smtp2.mail.be.easynet.net ([212.100.160.76])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19vXSK-0003W3-W4
	for nfs@lists.sourceforge.net; Sat, 06 Sep 2003 00:26:01 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <shsn0djm2ut.fsf@charged.uio.no>
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

NIC: Bus  2, device   8, function  0:
Ethernet controller: Intel Corp. 82801BD PRO/100 VE (LOM) Ethernet
Controller (rev 129).

Driver is the default from kernel linux-2.4.20-18.7:
CONFIG_EEPRO100=y

Kernel customisations:
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_ROOT_NFS=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_M686=y
All network drivers built in kernel.


-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
Sent: vrijdag 5 september 2003 21:51
To: nfsmailinglist@heessels.com
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] 'random' diskless clients hangs


>>>>> " " == nfsmailinglist  <nfsmailinglist@heessels.com> writes:

     > The clients still hang every few hours. There is nothing in the
     > logs.  When we change the rsize and wsize to 2048, the cleint
     > no longer crash but clients and server because extremely slow.

That is usually a sign of a networking problem. What kind of
NIC+driver are you using on the clients?

Also, what does that 'custom' mean on you client kernels? Have you
done anything other than to enable nfsroot?

Cheers,
  Trond




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
