From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 10:14:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
 <1114042784.17214.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-858191671-1114071252=:3889"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOWpw-0007jr-K1
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:15:00 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOWpv-0005LK-2m
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:15:00 -0700
To: esqueleto@tusofona.com
In-Reply-To: <1114042784.17214.11.camel@lade.trondhjem.org>
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

--789237761-858191671-1114071252=:3889
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.61.0504211014211.3889@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Wed, 20 Apr 2005, Trond Myklebust wrote:

>> Why? There is no Network!! Why the NFS mantain the connection? Should =
the NFS
>> umount the mount points?
>>
>
> Umm... Perhaps because there is a general consensus among NFS developer=
s
> that throwing away people's data, and killing off their processes
> without their consent might be a bad thing?

The problem is that it's hard to get rid of the mount even if you want.=20
There is no --force-I-really-want-this.


> If you want that sort of behaviour, then read all about the "soft" moun=
t
> option ("man 5 nfs", and http://nfs.sourceforge.net/#faq_d6).

I think Esqueleto wants a Solaris-type "umount -f". I'd like to have that=
=20
too.

Is there any bug in http://bugzilla.kernel.org/ that I can vote for?

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-858191671-1114071252=:3889--


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
