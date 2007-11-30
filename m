From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH 05/29] NFS: Ensure NFSv4 SETCLIENTID send buffer
	is large enough
Date: Fri, 30 Nov 2007 14:06:13 -0500
Message-ID: <762258BA-DCB8-4CD9-9FA2-B3026DAEB239@oracle.com>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
	<20071129194018.4170.16357.stgit@picasso.1015granger.net>
	<1196382722.20292.118.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IyBDV-0006IS-Aa
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:08:01 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IyBDa-0000Bn-4x
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 11:08:07 -0800
In-Reply-To: <1196382722.20292.118.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 29, 2007, at 7:32 PM, Trond Myklebust wrote:
> On Thu, 2007-11-29 at 14:40 -0500, Chuck Lever wrote:
>> Ensure that the RPC buffer size specified for NFSv4 SETCLIENTID  
>> procedures
>> matches what we are encoding into the buffer.  See the definition of
>> struct nfs4_setclientid {} and the encode_setclientid() function.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/nfs/nfs4xdr.c        |   10 ++++++----
>>  include/linux/nfs_xdr.h |   13 +++++++------
>>  2 files changed, 13 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index eae46f0..cb7a835 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -116,10 +116,12 @@ static int nfs4_stat_to_errno(int);
>>  #define decode_renew_maxsz	(op_decode_hdr_maxsz)
>>  #define encode_setclientid_maxsz \
>>  				(op_encode_hdr_maxsz + \
>> -				4 /*server->ip_addr*/ + \
>> -				1 /*Netid*/ + \
>> -				6 /*uaddr*/ + \
>> -				6 + (NFS4_VERIFIER_SIZE >> 2))
>> +				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
>> +				XDR_QUADLEN(48) /* sc_name */ + \
>> +				1 /* sc_prog */ + \
>> +				XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
>> +				XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
>> +				1) /* sc_cb_ident */
>>  #define decode_setclientid_maxsz \
>>  				(op_decode_hdr_maxsz + \
>>  				2 + \
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 58751f3..d740dfa 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -666,16 +666,17 @@ struct nfs4_rename_res {
>>  	struct nfs_fattr *		new_fattr;
>>  };
>>
>> +#define NFS4_SETCLIENTID_NAMELEN	(48)
>>  struct nfs4_setclientid {
>> -	const nfs4_verifier *		sc_verifier;      /* request */
>> +	const nfs4_verifier *		sc_verifier;
>>  	unsigned int			sc_name_len;
>> -	char				sc_name[48];	  /* request */
>> -	u32				sc_prog;          /* request */
>> +	char				sc_name[NFS4_SETCLIENTID_NAMELEN];
>> +	u32				sc_prog;
>>  	unsigned int			sc_netid_len;
>> -	char				sc_netid[4];	  /* request */
>> +	char				sc_netid[RPCBIND_MAXNETIDLEN];
>>  	unsigned int			sc_uaddr_len;
>> -	char				sc_uaddr[24];     /* request */
>> -	u32				sc_cb_ident;      /* request */
>> +	char				sc_uaddr[RPCBIND_MAXUADDRLEN];
>> +	u32				sc_cb_ident;
>>  };
>>
>>  struct nfs4_statfs_arg {
>
> Hmm... This one looks a little odd. On the one hand you've replaced
> sc_name[48] by sc_name[NFS4_SETCLIENTID_NAMELEN], but in
> encode_setclientid_maxsz you've hard-coded the 48 again...


Your causality is backwards.  I fixed encode_setclientid_maxsz first,  
then forgot to update it later when I added the  
NFS4_SETCLIENTID_NAMELEN macro.

I'll fix this and resend.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

