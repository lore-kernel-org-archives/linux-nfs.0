From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RFC: LSM/SELinux handling of mount options
Date: Fri, 13 Jul 2007 13:00:33 -0400
Message-ID: <4697AFB1.3090602@oracle.com>
References: <1184283693.3510.123.camel@localhost.localdomain>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070206000902030602080402"
Cc: steved@redhat.com, trond.myklebust@fys.uio.no, hch@infradead.org,
	nfs@lists.sourceforge.net, viro@zeniv.linux.org.uk,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9OWK-0004aU-2m
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:01:32 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9OWN-00047f-98
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:01:35 -0700
In-Reply-To: <1184283693.3510.123.camel@localhost.localdomain>
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
--------------070206000902030602080402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Eric -

Eric Paris wrote:
> So there are 2 overarching problems this patch set it attempting to
> solve or make later solutions easier.  
> 
> 1) NFS uses binary mount data (for both normal and nohide/referral
> mounts) which currently SELinux attempts to understand and use.  This
> was declared a layering issue, no security module should have FS
> specific data structure knowledge.  (Instead we have to put security
> module specific knowledge into the FS since the FS 'owns' the mount
> data, see below)

Please take a look at the string-ified NFS mount patches that are going 
into 2.6.23.  In the future we want to pass mount options for NFS mounts 
via a C string instead of a binary blob.  If nothing else, it will 
affect your changes to fs/nfs/super.c.


--------------070206000902030602080402
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


--------------070206000902030602080402
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070206000902030602080402
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070206000902030602080402--
