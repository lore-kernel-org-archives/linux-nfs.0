From: David Cureton <david.cureton@catapult.com>
Subject: Re: The missing link -
Date: Tue, 03 May 2005 08:21:07 +1000
Message-ID: <4276A7D3.4030804@catapult.com>
References: <4275DB78.8090603@catapult.com> <1115038201.10853.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSjHz-0001fc-AG
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 15:21:19 -0700
Received: from [192.94.66.29] (helo=catapult-mx.catapult.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DSjHx-0003Z2-Vw
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 15:21:19 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1115038201.10853.1.camel@lade.trondhjem.org>
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

Hi Trond and list,
    Firstly sorry for the triple posting - My email client indicated it=20
could not send, however it just could not put the mail in the sent=20
folder - seems it actually sent the mail just fine :-|

We are  exporting a reiser file system to the clients.=20
 =20
When the behavior is happening there is no '/server/Staff'  link in the=20
ls of '/server' however I have not explicitly tried to do
an  'ls -l /server/Staff' on when the link is missing. Good idea! Next=20
time I see the issue I will do this and report back.

Many thanks,
David


Trond Myklebust wrote:

>m=C3=A5 den 02.05.2005 Klokka 17:49 (+1000) skreiv David Cureton:
>
> =20
>
>>However on occasion we have noticed that the /server/Staff link just
>>disappears for some SuSE9.2 clients and the user no longer has access t=
o
>>there home directory. All other clients still have the link available
>>and they are fine.
>>   =20
>>
>
>What kind of filesystem are you exporting?
>
>When this behaviour happens, what does the client report when you do an
>'ls -l' on /server/Staff?
>
>Cheers,
>  Trond
> =20
>



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, =
4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=3D20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
