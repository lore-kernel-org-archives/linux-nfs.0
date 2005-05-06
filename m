From: David Cureton <david.cureton@catapult.com>
Subject: Re: ADV: Re: The missing link -
Date: Fri, 06 May 2005 16:50:22 +1000
Message-ID: <427B13AE.1020105@catapult.com>
References: <4275DB78.8090603@catapult.com> <1115038201.10853.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTwfQ-0007ge-UY
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 23:50:32 -0700
Received: from [192.94.66.29] (helo=catapult-mx.catapult.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DTwfO-0005eg-Ds
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 23:50:32 -0700
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

Hi Trond and List,
  =20
      It happened again today. The /server/Staff link went missing.

    "ls -l /server/Staff" explicitly specifying the missing link=20
returned an  "No such file or directory" error. =20
  =20
    "ls -l" in /server  on the effected client shows all but the=20
/server/Staff link.

        Previously I have monitored the NFS traffic where the client=20
does a getattr on the directory /server/Staff.
    Then if proceeds to getattr on the contents of the directory.=20
(Assuming it does not issue a getattr for /server/Staff. It is difficult=20
to map
the raw file handles onto the filenames. How can I do this?)

    Since the client is only doing getattr on the files and directories=20
I am assuming the client thinks that it's cache is OK  and proceeds with=20
it's local
    version of the truth. One that does not include the /server/Staff lin=
k.

    Therefore I tried the following:
       On the NFS server:  'touch test' in the /server diectory=20
therefore causing the client cache of /server to be invalid.
  =20
    On the client ls -la /server...... low and behold  the /server/Staff=20
link is back.

    Therefore it appears to be a client side issue.  It appears that the=20
client forgets about /server/Staff in it's cache?  Anyone else had this=20
issue?

Thanks,
    David





Trond Myklebust wrote:

>m=E5 den 02.05.2005 Klokka 17:49 (+1000) skreiv David Cureton:
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
