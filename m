From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 23 Aug 2007 13:45:52 -0400
Message-ID: <46CDC7D0.6030803@oracle.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040905060300080600090403"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOHB2-0005Al-Pd
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 11:13:05 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOHB5-0005to-Oo
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 11:13:09 -0700
In-Reply-To: <46CD82A0.1000408@redhat.com>
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
--------------040905060300080600090403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> Hi all-
>>
>> The recent addition of the chk_mountpoint() function in 
>> utils/mount/mount.c in nfs-utils commit 3b55934b has broken a 
>> particular behavior of background mounts.
>>
>> nfs(5) states that, if the "bg" option is specified, "A missing mount 
>> point is treated as a timeout, to allow for nested NFS mounts."
>>
>> If I try mounting an NFS share onto a non-existent directory while 
>> using the "bg" option, I now get an immediate failure:
>>
>>   mount.nfs: mount point /mnt/nothere does not exist
>>
>> instead of the mount backgrounding itself to wait for /mnt/nothere to 
>> show up.  This is because chk_mountpoint() is causing the mount 
>> request to fail immediately.
>>
>> Is the documented bg retry behavior still desirable? 
> 
> Isn't this what autofs is for?  To be able to handle hierarchies
> of mounts?

I think the purpose of this feature is to allow a sysadmin to specify a 
set of mount points in /etc/fstab, some possibly nested.  "mount -a 
-tnfs" should work no matter what order the mounts in /etc/fstab are 
specified.

After all, some servers may be unresponsive when the client boots -- the 
mounting order is nondeterministic; it can't be depended on, in any event.

We also don't know if the automounter itself depends on this feature.

--------------040905060300080600090403
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


--------------040905060300080600090403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040905060300080600090403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040905060300080600090403--
