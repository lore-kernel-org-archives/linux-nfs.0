From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 19:57:42 +0100
Message-ID: <41A236A6.4050104@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>	 <20041122153655.GH1291@suse.de>  <41A2280B.1010005@int-evry.fr> <1101146906.11196.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWJNv-0003Nc-Sl
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:57:59 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWJNu-0000gk-ME
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:57:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1101146906.11196.35.camel@lade.trondhjem.org>
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

>m=E5 den 22.11.2004 Klokka 18:55 (+0100) skreiv jehan.procaccia:
>
> =20
>
>>My users won't accept the sync performances !
>>   =20
>>
>
>Will they accept data loss in case of a server crash? If they don't
>care, then hey - you're safe...
> =20
>
in my old solaris 7 nfs it was async I suppose ! although we didn't lose=20
data, maybe we where risking it ... ? anyway now I move from and old=20
solaris NFS server to a brand new linux one with a SAN (AX100) Storage=20
Processor in Raid 5 an Fiber Channel attachement, how can I support=20
performances more than 50 times longer :-( with that config,  user and=20
manager wil tell me that I  spoild money on that new server !, there=20
must be a misconfiguration somewhere ?.

>BTW: I've never seen a slowdown as bad as that. Just out of curiosity,
>what happens if you turn off ACL support and/or use a client from
>ftp.kernel.org, with no ACL support.
> =20
>
I did it on the server export option (no_acl) , no better performance.=20
However I don't know why I have ACLs,  I nerver ask for it !?
/etc/fstab on the server
/dev/emcpowerp1         /p2v5f1         ext3   =20
defaults,usrquota,grpquota     1 2

>(NOTE: the reason I've rejected ACLs so far in the mainline client is
>the lack of support for caching in the patches I've seen so far)
>
>Cheers,
>  Trond
> =20
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
