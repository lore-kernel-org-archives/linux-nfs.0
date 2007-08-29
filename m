From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: fix length computation
	in	nfs_validate_mount_data
Date: Wed, 29 Aug 2007 17:06:06 -0400
Message-ID: <46D5DFBE.6030506@oracle.com>
References: <Pine.LNX.4.64.0708291509500.2779@jlentini-linux.nane.netapp.com>	
	<46D5D774.20908@oracle.com>
	<1188420008.6580.126.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030302040102050802040702"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUkP-0006Vh-2a
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:06:57 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUkS-00051a-9V
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:06:49 -0700
In-Reply-To: <1188420008.6580.126.camel@heimdal.trondhjem.org>
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
--------------030302040102050802040702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-08-29 at 16:30 -0400, Chuck Lever wrote:
>> Yep, this is the same fix as one provided in the clean-up/bug-fix 
>> patches I just resent today.
> 
> Sure, but we shouldn't be sending pure cleanups to Linus when we're
> already in an -rc4 release. OTOH, I'd like to fix genuine bugs like
> this, so I'll probably send in James' patch for now, and then let the
> cleanups lie until the 2.6.24 merge window opens.

Bruce already (sternly) lectured me on this.

These are not just clean-ups.  They really are bug-fixes for the API. 
I'm sorry I didn't recognize the semantic distinction in the patch 
description.

As Tom said, these really are needed to make the interface useful.

>> James Lentini wrote:
>>> While experimenting with the new string mount infrastructure, I 
>>> noticed an off by one error in the computation of the hostname's 
>>> length. This patch fixes the length computation to match the same 
>>> computation in nfs4_validate_mount_data().
>>>
>>> Signed-off-by: James Lentini <jlentini@netapp.com>
>>> ---
>>>
>>>  fs/nfs/super.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> --- fs/nfs/super.c	2007-08-29 15:06:59.320932000 -0400
>>> +++ fs/nfs/super.c	2007-08-29 15:07:51.439960000 -0400
>>> @@ -1153,7 +1153,7 @@ static int nfs_validate_mount_data(struc
>>>  		c = strchr(dev_name, ':');
>>>  		if (c == NULL)
>>>  			return -EINVAL;
>>> -		len = c - dev_name - 1;
>>> +		len = c - dev_name;
>>>  		if (len > sizeof(data->hostname))
>>>  			return -EINVAL;
>>>  		strncpy(data->hostname, dev_name, len);
> 


--------------030302040102050802040702
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------030302040102050802040702
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030302040102050802040702
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030302040102050802040702--
