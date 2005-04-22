From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Fri, 22 Apr 2005 09:12:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0504220857510.28175@maggie.lkpg.cendio.se>
References: <1114027379.4266b57354785@webmail.tusofona.com>
 <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>
  <1114042784.17214.11.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
 <1114088708.10727.9.camel@lade.trondhjem.org>
 <Pine.LNX.4.61.0504212119170.16285@maggie.lkpg.cendio.se>
 <1114118453.12750.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-269219917-1114153952=:28175"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOsLC-0006jd-3s
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 00:12:42 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DOsLA-0006gI-1S
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 00:12:41 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 7089125DB21
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 09:12:32 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1114118453.12750.44.camel@lade.trondhjem.org>
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

--789237761-269219917-1114153952=:28175
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Apr 2005, Trond Myklebust wrote:

>>> You didn't actually read that FAQ entry, that I pointed to, did you?
>>> Please do.
>>
>> I did not, because I thought it was only about soft mounts. I don't wa=
nt
>> soft mounts.
>>
>> I've read it now, but it didn't make me much wiser. It talks about sof=
t
>> mounts, which I don't want. It takes about killing processes, which I
>> don't want to do by hand: I think "umount -f" should suffice. The the
>> processes itself can decide what to do with the EIO.
>
> The kernel already aborts all pending I/O and returns EIO with "umount
> -f".

Interesting. How long has this been the case? I've never heard of it=20
before; i thought that "-f" was only for not careing about the UMNT call.

Perhaps the man-page could say something about this?

A few other interesting things: I've tested this on Fedora. I did a=20
"strace cat /mnt/foo". The first "umount -f" call gave:

# umount -f /mnt
umount2: Device or resource busy
umount: /mnt: device is busy
umount2: Device or resource busy
umount: /mnt: device is busy

The cat process was still hanged. When doing a second "umount -f",=20
open("/mnt/foo") returned EIO. This time, the umount command said:

# umount -f /mnt
umount2: Device or resource busy
umount: /mnt: device is bus

One other interesting thing was that then, the kernel crashed... I'm usin=
g=20
kernel 2.6.11-1.14_FC3.

I'm able to reproduce this problem. I have a screen shot of the call trac=
e=20
on http://www.cendio.se/~peter/fc3-umount-crash.png, if anyone is=20
interested.


> Three reasons:
>
>  1) That bugzilla is meant for reporting kernel bugs, not for feature
> requests

In my opinion, an "unkillable" process is a bug.


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-269219917-1114153952=:28175--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
