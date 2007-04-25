From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Wed, 25 Apr 2007 10:57:34 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0704251042390.8489@maggie.lkpg.cendio.se>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
	<20070424161027.GA30213@infradead.org> <462E38B9.5020808@RedHat.com>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
	<Pine.LNX.4.64.0704242053510.32688@maggie.lkpg.cendio.se>
	<462E6812.6040401@RedHat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1174483803-1177491454=:8489"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgdJm-0000EI-AJ
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 01:57:42 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgdJn-0001hj-Fc
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 01:57:45 -0700
In-Reply-To: <462E6812.6040401@RedHat.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1174483803-1177491454=:8489
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 24 Apr 2007, Steve Dickson wrote:

> Peter =C3=85strand wrote:
> > One thing that bothers me is that the current libtirpc[*] is different =
from
> > other TI-RPC versions. The current version (as far as I understand) is =
based
> > on a snapshot from FreeBSD, which is turn is based on Suns TIRPC 2.3. T=
his
> > code is *not* up to date with TI-RPC 2.9 (aka tirpcsrc_99) and certainl=
y not
> > with the latest OpenSolaris version.
> hmm... Were does one go to find out how to be come tirpcsrc_99
> compliant and why is this important? Does the TI-RPC 2.9
> use a different over-the-wire protocol? I surely hope not... :-\

The over-the-wire protocol should be the same. I'm not sure about the API,=
=20
but even if it's the same, I'm a bit worried that TI-RPC 2.9 contains=20
bugfixes or features that 2.3 is missing.=20

tirpcsrc_99 used to be available from sun.com, but it isn't anymore. I=20
have a copy at http://www.cendio.se/~astrand/oncrpc/, though.=20


> > Another problem with TI-RPC is that a Windows port seems to be hard. Th=
at's
> > one reason why I'm not porting unfs3 to TI-RPC.=20
> Wow... I didn't even know Windows had RPC support... but
> I kinda doubt we'll be port nfs-utils to Windows anytime
> soon.. :-)

Windows has a lot of different RPC mechanism, but Microsoft does not=20
support the ONC RPC API except that with "Services for UNIX". So if you=20
want to port an application that uses ONC RPC, without using SFU, you'll=20
need an external library. Many commercial ones are available. Several free=
=20
ones are also available, but as far as I understand, none of these are=20
maintained, except http://oncrpc-ms.sourceforge.net/ (which I maintain=20
myself :-).

nfs-utils on Windows doesn't make much sense, but there are other=20
applications that does. unfs3 is one of those. Besides, wouldn't it be=20
nice if developers could use ONC RPC a little bit often, instead of=20
solutions like SOAP ? :-)=20
(http://wanderingbarque.com/nonintersecting/2006/11/15/the-s-stands-for-sim=
ple/=20
is worth reading.)

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1174483803-1177491454=:8489
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--789237761-1174483803-1177491454=:8489
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1174483803-1177491454=:8489--
