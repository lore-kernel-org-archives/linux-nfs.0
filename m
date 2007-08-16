From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Mounting a partition at boot time from /etc/fstab
Date: Thu, 16 Aug 2007 11:11:41 -0400
Message-ID: <46C4692D.2020402@oracle.com>
References: <46C410E9.2030809@ambra.ro>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090002010806070807080604"
Cc: nfs@lists.sourceforge.net
To: Victor Sterpu <victor@ambra.ro>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILh5F-00056p-Ca
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 08:16:25 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILh5H-0006PA-Ah
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 08:16:29 -0700
In-Reply-To: <46C410E9.2030809@ambra.ro>
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
--------------090002010806070807080604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Victor-

Victor Sterpu wrote:
> I try to mount the /var partition at boot time.
> 
> I receive the following error at boot time:
> statd: server localhost not responding, time out
> lockd: cannot monitor 192.168.250.90
> lockd: failed to monitor 192.168.250.90
> 
> This is my /etc/fstab :
> proc            /proc           proc    defaults        0       0
> 192.168.250.90:/var/nfs/mail2.ambra.ro /var nfs defaults 0 0
> 
> When I do "mount 192.168.250.90:/var/nfs/mail2.ambra.ro /var" the 
> partition is mounted succesfuly.
> I use kernel 2.6.20 with nfs and automount support.
> 
> Haw can I mount this nfs partition at boot time?

Since the NFS file locking manager uses files in /var, you need to mount 
/var with the "nolock" mount option.  See nfs(5).

--------------090002010806070807080604
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


--------------090002010806070807080604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090002010806070807080604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090002010806070807080604--
