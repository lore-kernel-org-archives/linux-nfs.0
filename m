From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
	sign comparison
Date: Wed, 31 Oct 2007 21:53:08 -0400
Message-ID: <7D9707A4-3260-4ADA-9235-8DF945EA2EF9@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<1193857219.7454.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InPG7-000191-RP
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 18:54:12 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InPGC-0001PO-4o
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 18:54:17 -0700
In-Reply-To: <1193857219.7454.70.camel@heimdal.trondhjem.org>
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

On Oct 31, 2007, at 3:00 PM, Trond Myklebust wrote:
> On Wed, 2007-10-31 at 13:06 -0400, Talpey, Thomas wrote:
>> This is a serious vunerability! A huge string length will always be
>> accepted by this code, right? Security/integrity bug, not a minor
>> sign cleanup IOW.
>
> Wrong! The current code is quite correct.
>
> It trusts that the caller is setting a reasonable value for maxlen,  
> and
> assumes that 'len' is the untrusted value (since it comes from the
> network).
>
> in the comparison
>
>   ((len = ntohl(*p++)) < maxlen)
>
> then the trusted value maxlen is the one that gets cast to an unsigned
> value since 'len' and 'maxlen' are both integers of the same rank (see
> the description of the usual binary conversions in section 6.3.4 in
> Harbison and Steele).

Whatever H&S says, the compiler flags this as a mixed sign  
comparison.  Thus something is not working the way you assume it is.

[cel@ingres NFS_ALL]$ make net/sunrpc/xdr.o
   Using /home/cel/src/linux/NFS_ALL as source for kernel
   GEN     /u/cel/obj/Makefile
   CHK     include/linux/version.h
   CHK     include/linux/utsrelease.h
   UPD     include/linux/utsrelease.h
   CALL    /home/cel/src/linux/NFS_ALL/scripts/checksyscalls.sh
   CC      net/sunrpc/xdr.o
/home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c: In function  
xdr_decode_string_inplace:
/home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c:100: warning: comparison  
between signed and unsigned
[cel@ingres NFS_ALL]$

Line 100 is precisely:

	if ((len = ntohl(*p++)) > maxlen)

My gcc is the latest available for Fedora 7:

gcc version 4.1.2 20070925 (Red Hat 4.1.2-27)

I rather prefer spelling this out completely so that neither the  
compiler nor humans can mistake the intent of this logic.

> Chuck's patch _introduces_ the bug, since it causes the above  
> comparison
> to become a signed comparison. In that case, you also need to test for
> len<0.

Yes, the second version of the patch is incorrect.

> Trond
>
>> Tom.
>>
>> At 12:50 PM 10/31/2007, Chuck Lever wrote:
>>> xdr_decode_string_inplace() compares an incoming length to a  
>>> maximum length
>>> allowed by the protocol.  Make sure both sides of the comparison  
>>> have the
>>> same sign.
>>>
>>> A better fix for this would be always to use unsigned 32-bit  
>>> integers for
>>> string lengths.  To wit, RFC 4506 says:
>>>
>>> 4.2.  Unsigned Integer
>>>
>>>   An XDR unsigned integer is a 32-bit datum that encodes a non- 
>>> negative
>>>   integer in the range [0,4294967295].
>>>
>>> ...
>>>
>>> 4.11.  String
>>>
>>>   The standard defines a string of n (numbered 0 through n-1) ASCII
>>>   bytes to be the number n encoded as an unsigned integer (as  
>>> described
>>>   above), and followed by the n bytes of the string.
>>>
>>> This would mean fixing up the callers of  
>>> xdr_decode_string_inplace, which
>>> include the NFS server's filename handling functions (including
>>> decode_filename, decode_pathname, and nfsd_lookup), and lockd's  
>>> nlm_lock
>>> structure.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> net/sunrpc/xdr.c |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>>> index 3d1f7cd..db80a77 100644
>>> --- a/net/sunrpc/xdr.c
>>> +++ b/net/sunrpc/xdr.c
>>> @@ -95,7 +95,7 @@ xdr_encode_string(__be32 *p, const char *string)
>>> __be32 *
>>> xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int  
>>> maxlen)
>>> {
>>> -	unsigned int	len;
>>> +	int len;
>>>
>>> 	if ((len = ntohl(*p++)) > maxlen)
>>> 		return NULL;
>>>
>>>
>>> -------------------------------------------------------------------- 
>>> -----
>>> This SF.net email is sponsored by: Splunk Inc.
>>> Still grepping through log files to find problems?  Stop.
>>> Now Search log events and configuration files using AJAX and a  
>>> browser.
>>> Download your FREE copy of Splunk now >> http://get.splunk.com/
>>> _______________________________________________
>>> NFS maillist  -  NFS@lists.sourceforge.net
>>> https://lists.sourceforge.net/lists/listinfo/nfs
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
