From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 12/17] mount.nfs: Change *flags to flags
Date: Mon, 16 Jul 2007 00:03:04 -0400
Message-ID: <469AEDF8.50304@oracle.com>
References: <20070716031549.11209.79977.stgit@manray.1015granger.net>
	<18074.60613.359354.119674@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040105030005010302070008"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHoZ-0006iB-PL
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:04:03 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHoc-0000a9-5d
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:04:07 -0700
In-Reply-To: <18074.60613.359354.119674@notabene.brown>
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
--------------040105030005010302070008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Sunday July 15, chuck.lever@oracle.com wrote:
>> It's not necessary to treat the *flags parameter to nfsmount and nfs4mount
>> as an output parameter.  Nothing is passed back.  Replace it with a normal
>> call-by-value.
> 
> And, in fact, very little is passed forward.
> nfs4mount doesn't use 'flags' at all... maybe it should?
> nfsmount uses it for one thing - checking in MS_REMOUNT was set.
> So maybe we should change the name to 'remount' and pass down
> 'flags & MS_REMOUNT' ??

The earlier patch to move the mount system call into nfsmount.c will 
need the
whole set of flags.  Likewise for nfs4mount.c.

Note this is also why MS_USER and MS_USERS need to be moved into 
mount_constants.h !  ;-)

> Most of the stuff the nfsmount doesn't do if MS_REMOUNT is talking to
> mountd which obviously is not relevant for NFSv4.  But NFSv4 still
> tries to ping the server... Should that be excluded in MS_REMOUNT is
> set, do you think?

I can take a look at that as a separate clean up.

--------------040105030005010302070008
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


--------------040105030005010302070008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040105030005010302070008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040105030005010302070008--
