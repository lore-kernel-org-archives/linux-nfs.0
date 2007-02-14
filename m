From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 001 of 9] knfsd: nfsd4: fix non-terminated string
Date: Wed, 14 Feb 2007 09:55:25 -0800
Message-ID: <45D34D0D.3040606@oracle.com>
References: <20070213103941.28958.patches@notabene>	<1070212234402.29224@suse.de>
	<1171458018.2638.1.camel@localhost.localdomain>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020504000901040309000006"
Cc: NeilBrown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: blackmagic02881@gmail.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHOMV-0007tt-MR
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 09:56:14 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHOMO-0005ml-BJ
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 09:56:10 -0800
In-Reply-To: <1171458018.2638.1.camel@localhost.localdomain>
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
--------------020504000901040309000006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ming Zhang wrote:
> On Tue, 2007-02-13 at 10:44 +1100, NeilBrown wrote:
>> From: J. Bruce Fields <bfields@citi.umich.edu>
>> The server name is expected to be a null-terminated string, so we can't
>> pass in the raw client identifier.
>>
>> What's more, the client identifier is just a binary, not necessarily
>> printable, blob.  Let's just use the ip address instead.  The server
>> name appears to exist just to help debugging by making some printk's
>> more informative.
>>
>> Note that the string is copies into the rpc client structure, so
>> the pointer to the local variable does not outlive the function call.
>>
>> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
>> Signed-off-by: Neil Brown <neilb@suse.de>
>>
>> ### Diffstat output
>>  ./fs/nfsd/nfs4callback.c |    7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff .prev/fs/nfsd/nfs4callback.c ./fs/nfsd/nfs4callback.c
>> --- .prev/fs/nfsd/nfs4callback.c	2007-02-13 09:50:26.000000000 +1100
>> +++ ./fs/nfsd/nfs4callback.c	2007-02-13 10:00:59.000000000 +1100
>> @@ -387,7 +387,6 @@ nfsd4_probe_callback(struct nfs4_client 
>>  		.address	= (struct sockaddr *)&addr,
>>  		.addrsize	= sizeof(addr),
>>  		.timeout	= &timeparms,
>> -		.servername	= clp->cl_name.data,
>>  		.program	= program,
>>  		.version	= nfs_cb_version[1]->number,
>>  		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
>> @@ -397,6 +396,7 @@ nfsd4_probe_callback(struct nfs4_client 
>>  		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
>>  		.rpc_argp       = clp,
>>  	};
>> +	char clientname[16];
>>  	int status;
>>  
>>  	if (atomic_read(&cb->cb_set))
>> @@ -419,6 +419,11 @@ nfsd4_probe_callback(struct nfs4_client 
>>  	memset(program->stats, 0, sizeof(cb->cb_stat));
>>  	program->stats->program = program;
>>  
>> +	/* Just here to make some printk's more useful: */
>> +	snprintf(clientname, sizeof(clientname),
>> +		"%u.%u.%u.%u", NIPQUAD(addr.sin_addr));
> 
> can use NIPQUAD_FMT here instead of "%u.%u.%u.%u".
> 
> btw, will the ip address here possibly be an ipv6 address?

Some patches are in the works to build in IPv6 support.  See the patch 
series at http://oss.oracle.com/~cel/linux-2.6/2.6.19/patches/

--------------020504000901040309000006
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020504000901040309000006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------020504000901040309000006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020504000901040309000006--
