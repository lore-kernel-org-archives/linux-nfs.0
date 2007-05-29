From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 05/10] NFS: Fix compiler warnings
	in	fs/nfs/callback_xdr.c
Date: Tue, 29 May 2007 10:22:03 -0400
Message-ID: <465C370B.7030707@oracle.com>
References: <20070525214120.28668.92981.stgit@schiele.1015granger.net>
	<1180203643.5517.16.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090102090101090706010006"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ht2b9-0007dE-QC
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 07:22:55 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ht2b9-0004is-1d
	for nfs@lists.sourceforge.net; Tue, 29 May 2007 07:22:56 -0700
In-Reply-To: <1180203643.5517.16.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090102090101090706010006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/nfs/callback_xdr.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>> index 849a202..d664193 100644
>> --- a/fs/nfs/callback_xdr.c
>> +++ b/fs/nfs/callback_xdr.c
>> @@ -139,7 +139,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
>>  	if (unlikely(status != 0))
>>  		return status;
>>  	/* We do not like overly long tags! */
>> -	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ-12 || hdr->taglen < 0) {
>> +	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
>>  		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
>>  				__FUNCTION__, hdr->taglen);
>>  		return htonl(NFS4ERR_RESOURCE);
>> @@ -379,7 +379,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
>>  	}
>>  
>>  	maxlen = xdr_out->end - xdr_out->p;
>> -	if (maxlen > 0 && maxlen < PAGE_SIZE) {
>> +	if (maxlen > 0 && maxlen < (long) PAGE_SIZE) {
> 				     ^^^^^^ shouldn't be needed. We've just checked that maxlen > 0.

In this case, the "greater than zero" check is already there, so there 
isn't a bug.  However, PAGE_SIZE is defined as an "unsigned" value. 
Comparing it to maxlen, which is "signed", produces a compiler warning. 
  The explicit cast documents that the signed versus unsigned comparison 
is exactly what we want in this case.

Note that we included an explicit cast in the other fixes of this variety.

>>  		if (likely(status == 0 && op->decode_args != NULL))
>>  			status = op->decode_args(rqstp, xdr_in, argp);
>>  		if (likely(status == 0 && op->process_op != NULL))
>>


--------------090102090101090706010006
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------090102090101090706010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090102090101090706010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090102090101090706010006--
