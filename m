From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Thu, 30 Mar 2006 15:09:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603301453310.14417@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
 <1143641272.7928.13.camel@lade.trondhjem.org>
 <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
 <1143644879.7928.44.camel@lade.trondhjem.org>
 <Pine.LNX.4.64.0603292058050.15464@maggie.lkpg.cendio.se>
 <1143665569.7957.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1197128528-1143723464=:14417"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOwuV-0007vf-SU
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 05:09:59 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOwuU-0000WT-4q
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 05:09:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1143665569.7957.24.camel@lade.trondhjem.org>
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

--789237761-1197128528-1143723464=:14417
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.64.0603301457501.14417@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Mar 2006, Trond Myklebust wrote:

>>>>> The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.
>>>>
>>>> Does this mean that the manpage statement "The maximum timeout is al=
ways
>>>> 60 seconds." is incorrect?

>> -Better overall performance may be achieved by increasing the
>> +retransmission.  The maximum timeout is 60 seconds for UDP and 600
>> +seconds for TCP. Better overall performance may be achieved by increa=
sing
>> the
>>   timeout when mounting on a busy network, to a slow server, or throug=
h
>>   several routers or gateways.
>>   .TP 1.5i
>
> Yeah... Except I'm not sure we should keep the stuff about 'better
> overall performance...'. There are sections in the NFS-HOWTO that do a
> better job of describing the effect of these options.

I've made a new patch, see below.


>> Ok, so with the default values of timeo=3D7 and retrans=3D3, the first=
 major
>> timeout will occur after 0.7 + 1.4 + 2.8 =3D 4.9 seconds? And with sof=
t
>> mounts, this should return EIO to the application?
>>
>> In that case, how is it possible that I experience timeouts of 180
>> seconds?!?
>
> ...because default retransmission timeout value for tcp is timeo=3D60.

Don't you mean 600? 60 would give a timout of 6 + 12 + 24 =3D 42 seconds.


> Unlike UDP, TCP offers reliable transport, so the only times we should
> need to time out and retransmit is if the server is seriously out of
> resources and has to drop the request (in which case, we are better off
> delaying for a longer period in order to allow the server to recover).

With our thin clients, the most common case is that the client has=20
disconnected (thus, the server is no longer running), Or, the user might=20
have reconnected with NFS exports disabled, perhaps from a platform=20
without NFS export support.

We want something like 30 seconds of timeout. So, I guess we should aim=20
for timeo=3D40.


Here's the new man page patch. Should it be sent to Adrian Bunk?

diff -bur util-linux-2.13-pre7.org/mount/nfs.5 util-linux-2.13-pre7/mount=
/nfs.5
--- util-linux-2.13-pre7.org/mount/nfs.5	2002-06-27 23:31:33.000000000 +0=
200
+++ util-linux-2.13-pre7/mount/nfs.5	2006-03-30 15:04:45.000000000 +0200
@@ -39,18 +39,15 @@
  .IR wsize=3D8192 .)
  .TP 1.5i
  .I timeo=3Dn
-The value in tenths of a second before sending the
-first retransmission after an RPC timeout.
-The default value is 7 tenths of a second.  After the first timeout,
-the timeout is doubled after each successive timeout until a maximum
-timeout of 60 seconds is reached or the enough retransmissions
-have occured to cause a major timeout.  Then, if the filesystem
-is hard mounted, each new timeout cascade restarts at twice the
-initial value of the previous cascade, again doubling at each
-retransmission.  The maximum timeout is always 60 seconds.
-Better overall performance may be achieved by increasing the
-timeout when mounting on a busy network, to a slow server, or through
-several routers or gateways.
+The value in tenths of a second before sending the first
+retransmission after an RPC timeout.  The default value is 7 for UDP
+and 600 for TCP.  After the first timeout, the timeout is doubled
+after each successive timeout until a maximum timeout is reached or
+the enough retransmissions have occured to cause a major timeout.
+Then, if the filesystem is hard mounted, each new timeout cascade
+restarts at twice the initial value of the previous cascade, again
+doubling at each retransmission.  The maximum timeout is 60 seconds
+for UDP and 600 seconds for TCP.
  .TP 1.5i
  .I retrans=3Dn
  The number of minor timeouts and retransmissions that must occur before
@@ -175,8 +172,7 @@
  This is the default.
  .TP 1.5i
  .I intr
-If an NFS file operation has a major timeout and it is hard mounted,
-then allow signals to interupt the file operation and cause it to
+Allow signals to interupt the file operation and cause it to
  return EINTR to the calling program.  The default is to not
  allow file operations to be interrupted.
  .TP 1.5i

Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1197128528-1143723464=:14417--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
