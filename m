From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/8] SUNRPC: Use unsigned string lengths
	in	xdr_decode_string_inplace
Date: Fri, 02 Nov 2007 12:58:50 -0400
Message-ID: <472B574A.9040403@oracle.com>
References: <20071101205647.5503.42569.stgit@manray.1015granger.net>
	<18218.24424.760975.221813@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020304000904030405070404"
Cc: bfields@fieldses.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InztW-0000VA-Rx
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 10:01:19 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Inztb-0003sh-AC
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 10:01:24 -0700
In-Reply-To: <18218.24424.760975.221813@notabene.brown>
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
--------------020304000904030405070404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> Thanks Chuck.
> This series all:
>    Acked-By: NeilBrown <neilb@suse.de>
> 
> Just one question:
> 
>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> index fdc5e6d..31bd346 100644
>> --- a/net/sunrpc/xdr.c
>> +++ b/net/sunrpc/xdr.c
>> @@ -93,11 +93,13 @@ xdr_encode_string(__be32 *p, const char *string)
>>  }
>>  
>>  __be32 *
>> -xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
>> +xdr_decode_string_inplace(__be32 *p, char **sp,
>> +			  unsigned int *lenp, unsigned int maxlen)
>>  {
>> -	unsigned int	len;
>> +	u32 len;
> 
> What is the reason for making this a u32?  You seem to be happy with
> "unsigned int" everywhere else.
> 
> It's not important, but I'm curious.

It boils down to documenting exactly what comes off the wire, 
independent of what the local "unsigned int" is.

--------------020304000904030405070404
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


--------------020304000904030405070404
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------020304000904030405070404
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020304000904030405070404--
