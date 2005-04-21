From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 10:28:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504211025160.5061@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
 <1114042784.17214.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se> <4267639C.2090102@edsons.demon.nl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-2019453235-1114072102=:5061"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOX30-0008PK-Bf
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:28:30 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DOX2z-0001hA-Sf
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:28:30 -0700
To: Rudy Zijlstra <rudy@edsons.demon.nl>
In-Reply-To: <4267639C.2090102@edsons.demon.nl>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-2019453235-1114072102=:5061
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Apr 2005, Rudy Zijlstra wrote:

>>> Umm... Perhaps because there is a general consensus among NFS develop=
ers
>>> that throwing away people's data, and killing off their processes
>>> without their consent might be a bad thing?
>>=20
>>=20
>> The problem is that it's hard to get rid of the mount even if you want=
.=20
>> There is no --force-I-really-want-this.
>
> read up on lazy unmount

As I understand it, lazy umounts are not the same thing as forced umounts=
.=20
With lazy umounts, the process still hangs. With Solaris-type forced=20
umounts, the programs will get an error (EIO).

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-2019453235-1114072102=:5061--


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
