From: Jeff Blaine <jblaine@mitre.org>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Tue, 18 Jan 2005 09:54:55 -0500
Message-ID: <41ED233F.2070500@mitre.org>
References: <41E816B3.4030702@mitre.org> <1105747170.28849.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CqulA-0003ED-8Y
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 06:55:08 -0800
Received: from smtp-bedford-dr-x.mitre.org ([192.160.51.65] helo=smtp-bedford-dr.mitre.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cqul8-0002Jz-2N
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 06:55:07 -0800
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (8.11.6/8.11.6) with SMTP id j0IEt4O23253
	for <nfs@lists.sourceforge.net>; Tue, 18 Jan 2005 09:55:04 -0500
Received: from smtp-bedford-dr.mitre.org (localhost.localdomain [127.0.0.1])
	by smtp-bedford-dr.mitre.org (Postfix) with ESMTP id 368CC4F8D7
	for <nfs@lists.sourceforge.net>; Tue, 18 Jan 2005 09:55:04 -0500 (EST)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105747170.28849.22.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> fr den 14.01.2005 Klokka 14:00 (-0500) skreiv Jeff Blaine:
>=20
>>Can anyone tell me what is happening in the graph at the URL
>>below?  I can replicate it on any Linux box running 2.4.21
>>and changing rsize/wsize doesn't affect it at all.  This
>>was captured from a 2.6GHz P4 client machine.  Same thing
>>is visible with a Dual 3GHz Xeon box with 4GB memory as a
>>client.  A Solaris 9 client does not display this "falling
>>on face" behavior.
>>
>>http://www.kickflop.net/temp/sol9-server-linux2421-client-gigE-ag930m_1=
0533_image001.gif
>=20
> Firstly, you should always use the '-c' flag when measuring NFS client
> performance. Otherwise, you are basically just measuring the speed with
> which your machine can write to the local page cache (which may indeed
> explain your "knee" at 1MB here - that would be where the client starts
> to force a flush to disk).

Firstly,

Iozone manual:

     "If you use a file size that is larger than the amount of
      memory in the client then the =91c=92 flag is not needed."

I used a file size that is larger than the amount of memory in
the client.

> Secondly, have you actually read the NFS FAQ and NFS HOWTO entries on
> how to tune for performance? Particularly the entries on TCP vs. UDP,
> and how Solaris clients default to the former.

Secondly,

Yes, I have *actually* read the NFS FAQ and NFS HOWTO entries
on how to tune for performance.

It was a pretty simple question.  I don't know what all the
attitude is about.  Do you have an answer you can share with
me or not?

Anyone else?



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
