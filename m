From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/9] More mount.nfs clean-ups
Date: Mon, 27 Aug 2007 10:47:32 -0400
Message-ID: <46D2E404.5010004@oracle.com>
References: <20070824170602.10418.71987.stgit@monet.1015granger.net>
	<18127.22937.937135.74231@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000304020403000404040700"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPfuK-0007Dm-MD
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:49:36 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPfuL-0007lo-Rq
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:49:41 -0700
In-Reply-To: <18127.22937.937135.74231@notabene.brown>
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
--------------000304020403000404040700
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Friday August 24, chuck.lever@oracle.com wrote:
>> These patches clean up various hacks that were introduced with the recently
>> added text-based mount logic.  The biggest change is to improve the way the
>> 'addr=' and 'clientaddr=' mount options are handled.
> 
> All applied, thanks.

Thanks.  Jeff gave a good reason that I hadn't considered to allow 
sysadmins to specify clientaddr=, so I will probably be sending a patch 
that "reverts" the clientaddr= change.

And I'll make a note of the clientaddr= firewall requirement here:

http://wiki.linux-nfs.org/wiki/index.php/NewMountDesignSpec

--------------000304020403000404040700
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


--------------000304020403000404040700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000304020403000404040700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000304020403000404040700--
