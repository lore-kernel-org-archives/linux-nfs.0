From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Announcing cel's patchset for 2.4.20-rc4
Date: Tue, 16 Jan 2007 14:27:37 -0500
Message-ID: <45AD2729.2050703@oracle.com>
References: <45ACFC86.1070800@oracle.com>
	<1168975317.6056.4.camel@lade.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060304000509090308070704"
Cc: nfs@lists.sourceforge.net, Chris Mason <chris.mason@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H6tzV-0002RX-3n
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 11:29:05 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H6tzV-0004fK-J6
	for nfs@lists.sourceforge.net; Tue, 16 Jan 2007 11:29:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1168975317.6056.4.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060304000509090308070704
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Tue, 2007-01-16 at 11:25 -0500, Chuck Lever wrote:
>> I've posted a "technology preview" release of my patch set for 2.4.20 at 
>> oss.oracle.com:
>>
>>    http://oss.oracle.com/~cel/linux-2.4/2.4.20-rc4/
> 
> 2.4.20? Isn't that just a little bit past the cutoff date? :-)

Well, no.  ;-)

For the unfamiliar, I should have mentioned that this is the patch set 
that folks like NetApp use with 2.6.x to support their NFS over RDMA 
work.  I plan to submit a much smaller series of patches to the NFS list 
later this week that I'd like considered for 2.6.21...

--------------060304000509090308070704
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmUgTGludXggUHJvamVjdHMgR3Jv
dXANCmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRv
dCBjb20NCnRpdGxlOlByaW5jaXBsZSBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0
OCA2MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNh
cmQNCg0K
--------------060304000509090308070704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------060304000509090308070704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060304000509090308070704--
