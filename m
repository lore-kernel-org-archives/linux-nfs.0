From: =?ISO-8859-1?Q?J=E9r=F4me?= Warnier <jwarnier@beeznest.net>
Subject: Re: NFS TCP settings
Date: Wed, 21 Dec 2005 23:05:50 +0100
Message-ID: <1135202750.10000.23.camel@localhost>
References: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpC61-0002Lx-Sn
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 14:06:05 -0800
Received: from mailfe07.swip.net ([212.247.154.193] helo=swip.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EpC5z-0004ah-93
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 14:06:05 -0800
Received: from [83.182.16.181] (HELO aphrodite.beeznest.net)
  by mailfe07.swip.net (CommuniGate Pro SMTP 5.0.2)
  with ESMTP id 57474078 for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 23:05:51 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
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

Le mercredi 21 d=E9cembre 2005 =E0 08:32 -0800, Kenny Simpson a =E9crit :
> --- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > The NFS/RPC code has no direct control over the TCP window size. That
> > would be an issue for the networking people.
>=20
> I have tracked this a bit further, and am reporting back for completeness=
..
>=20
> The version of OnTap we are using (6.4.1p1) does not seem to support RFC =
1323 (large TCP windows),
> but the Linux client does.  The window scaling is communicated in the ini=
tial connection (SYN), so
> if ethereal does not catch that, it will incorrectly report the window si=
ze as the unscaled number
> - making the Linux client appear to be using a very small window.
> The reason it appeared that the small window size was being honored is a =
result of the direct
> crossover cable making the BDP (bandwidth-delay product) very small.
>=20
> As for the server side, because large TCP windows are not supported, the =
best it can do is 64k -
> which it does.  Running with GbE and jumbo packets fills the window quite=
 fast obviating the need
> for RFC 1323.
I'm experiencing big performance trouble with NFS on a GbE NIC (Intel
eepro1000) and a 2.6.8 kernel, to the point of NFS being unusable, and
having to force NIC to 100Mbs. The clients are 10/100 Mbs.
I've made no particular tuning on the server side for the GbE. Could
someone help me to get the most out of this GbE NIC?

Thanks

> Thanks to those who took the time to swing a clue stick in my direction.
>=20
> -Kenny




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
