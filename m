From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/14] SUNRPC: introduce rpcbind: replacement for
 in-kernel portmapper
Date: Fri, 19 Jan 2007 16:54:54 -0500
Message-ID: <45B13E2E.4060609@oracle.com>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233012.23310.70826.stgit@localhost.localdomain>
	<20070119000952.GB13473@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030909060002000303050005"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H81kB-0007JG-IG
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 13:57:55 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H81kC-00054E-QN
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 13:57:57 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070119000952.GB13473@infradead.org>
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
--------------030909060002000303050005
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by rgminet01.oracle.com id
	l0JLuu76008500

Christoph Hellwig wrote:
> On Thu, Jan 18, 2007 at 06:30:12PM -0500, Chuck Lever wrote:
>> Introduce a replacement for the in-kernel portmapper client that suppo=
rts
>> all 3 versions of the rpcbind protocol.  This code is not used yet.
>>
>> Original code by Groupe Bull updated for the latest kernel, with multi=
ple
>> bug fixes.
>>
>> Note that rpcb_clnt.c does not yet support registering via versions 3 =
and
>> 4 of the rpcbind protocol.
>=20
> I don't quite like the way you introduce rcpbind.  It exports the same
> API as the old portmap service, just using the rpcb_ prefix instead
> of rpc_.  Why don't you transpar=EF=BF=BDntly switch over the implement=
ation to
> the new model?

Using a different name means both the old and new implementation can=20
coexist in the kernel until we're sure the new one is working correctly.=20
    This is a widely-used change management technique.

In addition, the new naming echoes the API naming scheme used in user spa=
ce.

> More comments on the actual code:
>=20
>> --- /dev/null
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -0,0 +1,539 @@
>> +/*
>> + * linux/net/sunrpc/rpcb_clnt.c
>=20
> Please don't mention the filename in the top of file comment.  It's use=
less
> and even worse easily gets out of sync and confuses people then.

Done.

>> +static inline struct rpcbind_args *rpcb_map_alloc(void)
>> +{
>> +	return kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
>> +}
>> +
>> +static inline void rpcb_map_free(struct rpcbind_args *map)
>> +{
>> +	kfree(map);
>> +}
>=20
> Please kill these useless wrappers.

I don't agree that these are useless.  This is a common defensive=20
programming technique that is used throughout the Linux NFS and RPC=20
implementation.  Placing these two functions next to each other=20
documents in 9 lines of code which memory pool is used for rpcb_maps,=20
and ensures that if the memory pool is changed, every instance of=20
allocation and release is affected.  It also enforces the pointer types=20
automatically.

>> +static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *=
srvaddr, int proto, int version, int privileged)
>=20
> Please make sure to properly break lines after 80 chars.

Done.

--------------030909060002000303050005
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Disposition: attachment;
 filename="chuck.lever.vcf"
Content-Transfer-Encoding: base64

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmUgTGludXggUHJvamVjdHMgR3Jv
dXANCmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRv
dCBjb20NCnRpdGxlOlByaW5jaXBsZSBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0
OCA2MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNh
cmQNCg0K
--------------030909060002000303050005
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------030909060002000303050005
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030909060002000303050005--
