From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/5] mount.nfs: Add new files for supporting
 string-ified mount options
Date: Fri, 10 Aug 2007 17:07:26 -0400
Message-ID: <46BCD38E.3000809@oracle.com>
References: <20070809213706.16767.89918.stgit@monet.1015granger.net>
	<18107.50044.333597.209861@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060909050402000204090900"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJbiT-0000XG-5k
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 14:08:17 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJbiW-0000j1-0w
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 14:08:21 -0700
In-Reply-To: <18107.50044.333597.209861@notabene.brown>
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
--------------060909050402000204090900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Thursday August 9, chuck.lever@oracle.com wrote:
>> Introduce support files which contain code that builds string mount
>> options and passes them to the kernel.  This is a pre-requisite for
>> actually enabling /sbin/mount.nfs to do text-based mounts.
>>
>> This is only partially complete at the moment, but is presented so that
>> folks can start banging on the kernel mount option string parsing code.
>> There are clearly still parts that are not implemented quite yet, such
>> as bg and retry support, but it should be enough to get going.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
> 
>> +
>> +static int retry_opt = 10000;		/* 10,000 minutes ~= 1 week */
> 
> Why one week?  Why not "MAX_INT"? retry_opt is never actually used, so
> I cannot guess.

retry=10000 is the default setting.  According to the nfs(5) man page, 
this is about 1 week.

The plan is to extract the retry setting from the mount options string 
if it exists, and use the default value of 10000 if it does not.

--------------060909050402000204090900
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


--------------060909050402000204090900
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060909050402000204090900
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060909050402000204090900--
