From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 11:02:35 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EBD2@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <mci-unix@int-evry.fr>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWJSY-0003oP-AW
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:02:46 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWJSU-00015c-5D
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:02:46 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

> in my old solaris 7 nfs it was async I suppose ! although we=20
> didn't lose data, maybe we where risking it ... ?

the Solaris NFS server doesn't support an "async" mode.

> anyway now I move from and old=20
> solaris NFS server to a brand new linux one with a SAN=20
> (AX100) Storage=20
> Processor in Raid 5 an Fiber Channel attachement, how can I support=20
> performances more than 50 times longer :-( with that config, =20
> user and=20
> manager wil tell me that I  spoild money on that new server !, there=20
> must be a misconfiguration somewhere ?.

take a walk through the NFS how-to http://nfs.sourceforge.net/howto/ to
see if there is anything useful there.

also, you could measure your file system performance locally on the NFS
server instead of via an NFS client to see if your RAID and local file
system is configured correctly.

finally, you should look at raw network performance between your clients
and server to make sure you are not losing any performance there.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
