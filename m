From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 21:26:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
  <1114042784.17214.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
 <1114088708.10727.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1884212515-1114111204=:16285"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOhKH-0007gd-Ru
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 12:27:01 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOhK9-0004q3-8D
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 12:27:01 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id F258D25DB21
	for <nfs@lists.sourceforge.net>; Thu, 21 Apr 2005 21:26:45 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1114088708.10727.9.camel@lade.trondhjem.org>
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

--789237761-1884212515-1114111204=:16285
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.61.0504212120172.16285@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Apr 2005, Trond Myklebust wrote:

> to den 21.04.2005 Klokka 10:14 (+0200) skreiv Peter =C5strand:
>>> If you want that sort of behaviour, then read all about the "soft" mo=
unt
>>> option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).
>>
>> I think Esqueleto wants a Solaris-type "umount -f". I'd like to have t=
hat
>> too.
>
> You didn't actually read that FAQ entry, that I pointed to, did you?
> Please do.

I did not, because I thought it was only about soft mounts. I don't want=20
soft mounts.

I've read it now, but it didn't make me much wiser. It talks about soft=20
mounts, which I don't want. It takes about killing processes, which I=20
don't want to do by hand: I think "umount -f" should suffice. The the=20
processes itself can decide what to do with the EIO.


> This is not something that will happen soon, unless you or someone else=
=20
> who feels strongly about it pulls up their sleeves, and starts=20
> developing. Adding bugzilla entries for this type of feature will just=20
> serve to annoy.

I'm patient. I don't understand why people are annoyed by bugzilla=20
entries, though.


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1884212515-1114111204=:16285--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
