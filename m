From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 16:33:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0603291625370.7796@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
 <1143641272.7928.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1199991630-1143642829=:7796"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FObkF-0006ZK-A1
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 06:33:59 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FObkD-0002W0-QJ
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 06:33:59 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 6D63A25DB23
	for <nfs@lists.sourceforge.net>; Wed, 29 Mar 2006 16:33:49 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1143641272.7928.13.camel@lade.trondhjem.org>
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

--789237761-1199991630-1143642829=:7796
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Mar 2006, Trond Myklebust wrote:

> On Wed, 2006-03-29 at 09:44 +0200, Peter =C5strand wrote:
>> Hi. We are using unfsd to provide "personal" mounts in a thin client
>> environment, based on NFSv3 over TCP over SSH. This works fairly good,=
 but
>> we would like a little shorter timeout when the server doesn't respond

>> * How can we lower the timeouts? To me, it seems like the hardcoded
>>    maximum timeout of 60 seconds is a bit of a problem. How about
>>    introducing an option for changing this?
>
> The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.

Does this mean that the manpage statement "The maximum timeout is always=20
60 seconds." is incorrect?


>>    If we start using, say, retrans=3D1, does this mean that applicatio=
ns can
>>    recieve EIO after as little as 1 second?
>
> No. "timeo" controls the timeout value. "retrans" controls the number o=
f
> retransmissions before a major timeout is declared.

Yes, but the manpage states that EIO is reported when a major timeout=20
occurs. So, the time until EIO must be influenced by "retrans", right?


>> * Is it true that all the "-f" option to umount does is skip trying
>>    MOUNTPROC_UMNT?
>
> No. '-f' causes all pending RPC calls to be cancelled (and return -EIO)=
.

Is MOUNTPROC_UMNT tried even when -f is specified?


>> * About "intr": The man page says "If an NFS file operation has a majo=
r
>>    timeout and it is hard mounted". Does "intr" affect soft mounts in =
any
>>    way, or is it better to remove it?
>
> Intr changes the set of signals that are able to interrupt an RPC call.
> It has nothing to do with "soft".

That is - it has no effect when "soft" is used?

I'm still eager to hear some ideas on how the timeouts can be lowered.

Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1199991630-1143642829=:7796--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
