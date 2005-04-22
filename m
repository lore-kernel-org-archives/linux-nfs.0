From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Fri, 22 Apr 2005 16:24:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504221620000.1212@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
  <1114042784.17214.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
 <1114088708.10727.9.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
 <1114118453.12750.44.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
 <1114176705.10450.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1259965067-1114179899=:1212"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOz5i-0001C9-9O
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 07:25:10 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DOz5g-0005G7-El
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 07:25:10 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 7225D25DB21
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 16:24:59 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1114176705.10450.43.camel@lade.trondhjem.org>
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

--789237761-1259965067-1114179899=:1212
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Fri, 22 Apr 2005, Trond Myklebust wrote:

>> One other interesting thing was that then, the kernel crashed... I'm u=
sing
>> kernel 2.6.11-1.14_FC3.
>>
>> I'm able to reproduce this problem. I have a screen shot of the call t=
race
>> on http://www.cendio.se/~peter/fc3-umount-crash.png, if anyone is
>> interested.
>
> That's certainly an "interesting" Oops. ebp=3D0x1b, esp=3D0xc0446f98,
> together with a timer list corruption. Is that running under vmware?

Yes.


> If so, can you reproduce with a normal kernel (no vmware module) and=20
> given that weird value of ebp, with stack overflow checking turned on.

Perhaps I'll find time for this, I can't promise anything.


>> In my opinion, an "unkillable" process is a bug.
>
> That's entirely _your_ personal opinion. A lot of other people will
> argue that causing processes to lose data is a bug.

IMHO, if you use "kill -9", you should prepare for losing data (lying in=20
the process you are killing) anyway, no matter what kind of file systems=20
are you using.

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1259965067-1114179899=:1212--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
