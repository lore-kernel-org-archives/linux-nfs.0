From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Fix xdr_decode_string_inplace() mixed
 sign comparison
Date: Wed, 31 Oct 2007 13:56:49 -0400
Message-ID: <4728C1E1.7060006@oracle.com>
References: <20071031165045.5861.52308.stgit@manray.1015granger.net>
	<EXNANE01v6EybqfAj810000085a@exnane01.hq.netapp.com>
	<4728BB6E.2050104@oracle.com>
	<EXNANE014r3mbfJ8VrR0000085c@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030806000702040902070302"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InHop-0004Sn-Tl
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:57:32 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InHos-00026Y-Vj
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 10:57:37 -0700
In-Reply-To: <EXNANE014r3mbfJ8VrR0000085c@exnane01.hq.netapp.com>
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
--------------030806000702040902070302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 01:29 PM 10/31/2007, Chuck Lever wrote:
>> My proposal is to make all the variables in xdr_decode_string_inplace of 
>> type u32, and then work backwards into the ULPs, changing the length 
>> variables of type int to type u32.
> 
> I'd suggest a slight variation - using u32 where the variables shadow
> objects which are decoded/encoded off the wire, but using a native
> type (unsigned int/int) after they are actually passed outside xdr.

Converting XDR types to native types makes sense, I guess.

> For example, the length here is u32 within the xdr routine, but after
> it's decoded, it's really not something we'd want to pass to
> memcpy. IOW, it seems ok to me to have the "maxlen" argument
> remain an int (maybe unsigned), but the internal "len" is naturally u32.

I can't see why we need to handle negative string length values in most 
places, so the length variables should be made unsigned, at least. 
Trond insisted that *lenp and maxlen must be same type here.

However, it seems to me that native string lengths should be size_t. 
(ie the same type that strlen() returns).

--------------030806000702040902070302
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


--------------030806000702040902070302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------030806000702040902070302
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030806000702040902070302--
