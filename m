From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RPC client transport switch design documentation
Date: Tue, 21 Aug 2007 18:12:51 -0400
Message-ID: <46CB6363.8040704@oracle.com>
References: <46CA477B.6070003@oracle.com>
	<EXNANE013ednHM3SOlb00000044@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030301010906070402040409"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INbz5-0002ms-TZ
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 15:14:00 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INbz8-0002vl-6C
	for nfs@lists.sourceforge.net; Tue, 21 Aug 2007 15:14:04 -0700
In-Reply-To: <EXNANE013ednHM3SOlb00000044@exnane01.hq.netapp.com>
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
--------------030301010906070402040409
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 10:01 PM 8/20/2007, Chuck Lever wrote:
>>   http://wiki.linux-nfs.org/wiki/index.php/RpcClientTransportSwitch
>>
>> Is this the most recent version you remember?  I culled it from my 
>> 2.6.11 patchset from two and a half years ago.
> 
> Yep, I think it's the most recent version. The only other documents
> I remember were the original design plans, and this writeup included
> whatever was useful in them. I did have some ancillary docs on the
> mount API rpc requirements, but those would probably be best kept
> separate, even if they were current.
> 
> Are you updating the document above, or do you need comments/help
> on it now?

I'm planning to bring it up to reflect the current interface, then open 
it for review and updates.

After that, I'm not sure whether to leave it in the wiki, or put it in 
the mainline kernel under Documentation/ .

--------------030301010906070402040409
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------030301010906070402040409
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030301010906070402040409
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030301010906070402040409--
