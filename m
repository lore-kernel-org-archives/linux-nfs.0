From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace()
 mixed	sign comparison
Date: Thu, 01 Nov 2007 11:37:06 -0400
Message-ID: <4729F2A2.4030505@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>	
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>	
	<1193857219.7454.70.camel@heimdal.trondhjem.org>	
	<7D9707A4-3260-4ADA-9235-8DF945EA2EF9@oracle.com>
	<1193889489.7511.17.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060406030402010404090902"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inc77-0008P3-Ay
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 08:37:45 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Inc7C-0001kF-LU
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 08:37:51 -0700
In-Reply-To: <1193889489.7511.17.camel@heimdal.trondhjem.org>
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
--------------060406030402010404090902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-10-31 at 21:53 -0400, Chuck Lever wrote:
>> On Oct 31, 2007, at 3:00 PM, Trond Myklebust wrote:
>>> On Wed, 2007-10-31 at 13:06 -0400, Talpey, Thomas wrote:
>>>> This is a serious vunerability! A huge string length will always be
>>>> accepted by this code, right? Security/integrity bug, not a minor
>>>> sign cleanup IOW.
>>> Wrong! The current code is quite correct.
>>>
>>> It trusts that the caller is setting a reasonable value for maxlen,  
>>> and
>>> assumes that 'len' is the untrusted value (since it comes from the
>>> network).
>>>
>>> in the comparison
>>>
>>>   ((len = ntohl(*p++)) < maxlen)
>>>
>>> then the trusted value maxlen is the one that gets cast to an unsigned
>>> value since 'len' and 'maxlen' are both integers of the same rank (see
>>> the description of the usual binary conversions in section 6.3.4 in
>>> Harbison and Steele).
>> Whatever H&S says, the compiler flags this as a mixed sign  
>> comparison.  Thus something is not working the way you assume it is.
>>
>> [cel@ingres NFS_ALL]$ make net/sunrpc/xdr.o
>>    Using /home/cel/src/linux/NFS_ALL as source for kernel
>>    GEN     /u/cel/obj/Makefile
>>    CHK     include/linux/version.h
>>    CHK     include/linux/utsrelease.h
>>    UPD     include/linux/utsrelease.h
>>    CALL    /home/cel/src/linux/NFS_ALL/scripts/checksyscalls.sh
>>    CC      net/sunrpc/xdr.o
>> /home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c: In function  
>> xdr_decode_string_inplace:
>> /home/cel/src/linux/NFS_ALL/net/sunrpc/xdr.c:100: warning: comparison  
>> between signed and unsigned
>> [cel@ingres NFS_ALL]$
>>
>> Line 100 is precisely:
>>
>> 	if ((len = ntohl(*p++)) > maxlen)
> 
> Which is still correct according to both the old and new C standards. I
> know you've got that book at home...
> 
>> My gcc is the latest available for Fedora 7:
>>
>> gcc version 4.1.2 20070925 (Red Hat 4.1.2-27)
>>
>> I rather prefer spelling this out completely so that neither the  
>> compiler nor humans can mistake the intent of this logic.
> 
> That's fine, but please do not change the logic. The correct change is
> to replace the maxlen parameter with an unsigned int.

That's what I sent you originally.  You rejected it:

On October 26, 2007 at 14:24 -0400, Trond Myklebust said:
>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> index 3d1f7cd..ff16bab 100644
>> --- a/net/sunrpc/xdr.c
>> +++ b/net/sunrpc/xdr.c
>> @@ -93,7 +93,7 @@ xdr_encode_string(__be32 *p, const char *string)
>>  }
>>  
>>  __be32 *
>> -xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
>> +xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, unsigned int maxlen)
>>  {
>>  	unsigned int	len;
 >
> Nope. maxlen should be of the same type as *lenp.
> 
> Trond

Thus I now argue that both *lenp and maxlen should either be unsigned 
integers or size_t.  Negative string lengths make no sense whatsoever.

If we change both arguments, then we should also change the callers, at 
least to be consistent.

--------------060406030402010404090902
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


--------------060406030402010404090902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------060406030402010404090902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060406030402010404090902--
