From: "K.R. Foley" <kr@cybsft.com>
Subject: Re: NFS Latencies
Date: Fri, 27 Aug 2004 10:44:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412F56E5.3010502@cybsft.com>
References: <412E9EC5.6030106@cybsft.com> <200408270958.53498.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0iuW-0001SZ-3M
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 08:45:04 -0700
Received: from mail3.utc.com ([192.249.46.192])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C0iuT-0001ES-J3
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 08:45:04 -0700
Received: (from uucp@localhost)
	by mail3.utc.com (8.10.0/8.10.0) id i7RFiti14707
	for <nfs@lists.sourceforge.net>; Fri, 27 Aug 2004 11:44:55 -0400 (EDT)
Received: from swdev14.rkd.snds.com (ndcvba1.utc.com [192.249.49.31])
	by uusnwa0n.utc.com (Switch-2.2.8/Switch-2.2.8) with ESMTP id i7RFipT18343
	for <nfs@lists.sourceforge.net>; Fri, 27 Aug 2004 11:44:52 -0400 (EDT)
To: vincent.roqueta@ext.bull.net
In-Reply-To: <200408270958.53498.vincent.roqueta@ext.bull.net>
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

Vincent ROQUETA wrote:
> Le Vendredi 27 Ao=FBt 2004 04:39, K.R. Foley a =E9crit :
>=20
>>I have found some rather lengthy latencies related to NFS on Linux. Is
>>this the right place to bring those up?
>>
>>kr
>=20
>=20
>=20
>=20
> Can you tell me were are the latencie?. I am working on performances of=
 NFSv4=20
> linux implementation=20
>=20
> Vincent
>=20

I have several latency traces generated from running the NFS-COMPILE=20
test in the stress-kernel package. You can see them here:

http://www.cybsft.com/testresults/2.6.8.1-P9.NFS/

I think that most of these have to do with the code not being preemptable.

kr




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
