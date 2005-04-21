From: Rudy Zijlstra <rudy@edsons.demon.nl>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 10:56:25 +0200
Message-ID: <42676AB9.4010503@edsons.demon.nl>
References: <1114027379.4266b57354785@webmail.tusofona.com>  <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com> <1114042784.17214.11.camel@lade.trondhjem.org> <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se> <4267639C.2090102@edsons.demon.nl> <Pine.LNX.4.61.0504211025160.5061@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOXPU-0001An-2N
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:51:44 -0700
Received: from smtpq3.home.nl ([213.51.128.198])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOXPS-0000ZM-9e
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 01:51:43 -0700
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0504211025160.5061@maggie.lkpg.cendio.se>
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

Peter =C5strand wrote:

> On Thu, 21 Apr 2005, Rudy Zijlstra wrote:
>
>>>> Umm... Perhaps because there is a general consensus among NFS=20
>>>> developers
>>>> that throwing away people's data, and killing off their processes
>>>> without their consent might be a bad thing?
>>>
>>>
>>>
>>> The problem is that it's hard to get rid of the mount even if you=20
>>> want. There is no --force-I-really-want-this.
>>
>>
>> read up on lazy unmount
>
>
> As I understand it, lazy umounts are not the same thing as forced=20
> umounts. With lazy umounts, the process still hangs. With Solaris-type=20
> forced umounts, the programs will get an error (EIO).
>
True, it may still solve the problem of the OP.


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
