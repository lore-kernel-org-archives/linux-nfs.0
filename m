From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 18:48:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B4CA68.5020809@byggmek.lth.se>
References: <40B44FE7.6010601@byggmek.lth.se> <1085587915.3763.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT1aE-0000dn-OL
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:48:50 -0700
Received: from av2-2-sn3.vrr.skanova.net ([81.228.9.108])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BT1aE-0005CX-8N
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:48:50 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085587915.3763.12.camel@lade.trondhjem.org>
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

>P=E5 on , 26/05/2004 klokka 04:05, skreiv Jonas Lindemann:
> =20
>
>>Hi!
>>
>>We have an file server runninng RHEL3 and NFS. Clients are RHEL3 and=20
>>FC1. We are having problems with an service that want's to change the=20
>>executable bit on a file located on the NFS exported filesystem. The=20
>>service is running on RHEL3.
>>   =20
>>
>
>So basically, you are changing the executable bit on the server, and
>wondering why that changes isn't propagated instantly to the client?
>
>It's 'cos NFS client poll the server for attribute changes. The mount
>options that govern the polling period is documented in the "nfs"
>manpage (see the ac* flags).
> =20
>
Sorry. I didn't explain it very well before. The system is a cluster=20
with a front-end running grid-middleware. A file server (a different=20
machine from the front-end) exports a number of filesystems both to the=20
front-end and to the nodes. On the front-end the middleware tries to set=20
the executable bit and fails with the described problem.

-- Jonas

>Cheers,
>  Trond
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id149&alloc_id=8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
> =20
>




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
