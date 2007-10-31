From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
 sign comparison
Date: Wed, 31 Oct 2007 13:29:18 -0400
Message-ID: <4728BB6E.2050104@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000303040602030503070708"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InHOC-0001Mi-5m
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:30:00 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InHOH-0004YG-EB
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:30:05 -0700
In-Reply-To: <EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
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
--------------000303040602030503070708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> This is a serious vunerability! A huge string length will always be
> accepted by this code, right?

In the current code, a sufficiently large length coming from the wire 
will be treated as a negative value, thus will not be detected by the 
maximum length check in xdr_decode_string_inplace.

> Security/integrity bug, not a minor
> sign cleanup IOW.

My proposal is to make all the variables in xdr_decode_string_inplace of 
type u32, and then work backwards into the ULPs, changing the length 
variables of type int to type u32.

Note however that we also have to worry about open-coded string 
decoding, and the lengths of variable-length opaques.  I haven't even 
looked at those yet.

> Tom.
> 
> At 12:50 PM 10/31/2007, Chuck Lever wrote:
>> xdr_decode_string_inplace() compares an incoming length to a maximum length
>> allowed by the protocol.  Make sure both sides of the comparison have the
>> same sign.
>>
>> A better fix for this would be always to use unsigned 32-bit integers for
>> string lengths.  To wit, RFC 4506 says:
>>
>> 4.2.  Unsigned Integer
>>
>>   An XDR unsigned integer is a 32-bit datum that encodes a non-negative
>>   integer in the range [0,4294967295].
>>
>> ...
>>
>> 4.11.  String
>>
>>   The standard defines a string of n (numbered 0 through n-1) ASCII
>>   bytes to be the number n encoded as an unsigned integer (as described
>>   above), and followed by the n bytes of the string.
>>
>> This would mean fixing up the callers of xdr_decode_string_inplace, which
>> include the NFS server's filename handling functions (including
>> decode_filename, decode_pathname, and nfsd_lookup), and lockd's nlm_lock
>> structure.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/xdr.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> index 3d1f7cd..db80a77 100644
>> --- a/net/sunrpc/xdr.c
>> +++ b/net/sunrpc/xdr.c
>> @@ -95,7 +95,7 @@ xdr_encode_string(__be32 *p, const char *string)
>> __be32 *
>> xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
>> {
>> -	unsigned int	len;
>> +	int len;
>>
>> 	if ((len = ntohl(*p++)) > maxlen)
>> 		return NULL;
>>
>>
>> -------------------------------------------------------------------------
>> This SF.net email is sponsored by: Splunk Inc.
>> Still grepping through log files to find problems?  Stop.
>> Now Search log events and configuration files using AJAX and a browser.
>> Download your FREE copy of Splunk now >> http://get.splunk.com/
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs

--------------000303040602030503070708
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
version:2.1
end:vcard


--------------000303040602030503070708
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------000303040602030503070708
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000303040602030503070708--
