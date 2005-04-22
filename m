From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Fri, 22 Apr 2005 16:28:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504221625110.1212@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
  <1114042784.17214.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
 <1114088708.10727.9.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
 <1114118453.12750.44.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
 <1114176705.10450.43.camel@lade.trondhjem.org> <1114177382.10450.54.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="=-6zvSqInpFjH6ACMVtKY5"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOz8p-0001IA-1N
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 07:28:23 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DOz8o-0005fj-BF
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 07:28:22 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 6AC5C25DB20
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 16:28:16 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1114177382.10450.54.camel@lade.trondhjem.org>
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

--=-6zvSqInpFjH6ACMVtKY5
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.61.0504221625112.1212@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Fri, 22 Apr 2005, Trond Myklebust wrote:

>>> I'm able to reproduce this problem. I have a screen shot of the call =
trace
>>> on http://www.cendio.se/~peter/fc3-umount-crash.png, if anyone is
>>> interested.

>> That's certainly an "interesting" Oops. ebp=3D0x1b, esp=3D0xc0446f98,
>> together with a timer list corruption. Is that running under vmware? I=
f
>> so, can you reproduce with a normal kernel (no vmware module) and give=
n
>> that weird value of ebp, with stack overflow checking turned on.

> Could you describe the test you are using to reproduce your Oops in mor=
e
> detail? How are you causing the network partition?

I'm using FC3 as both host and guest OS. The host OS is running the NFS=20
server. My exports file looks like:

/mp3             *

There's only one single file below /mp3: /mp3/foo. The network stays up=20
all the time, but I did "service nfs stop" on the host before doing=20
"strace cat /mnt/foo" in the guest OS.

(I'm away over the weekend, but I will be back on monday. Have a nice=20
weekend, all of you.)

Regards,
--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--=-6zvSqInpFjH6ACMVtKY5--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
