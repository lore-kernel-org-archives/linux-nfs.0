From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Autofs problem while using new nfs-utils package
Date: Mon, 08 Oct 2007 11:58:22 -0400
Message-ID: <470A539E.6090509@oracle.com>
References: <200710060219.20536.mike@cs.mun.ca>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040802010503090109060209"
Cc: nfs@lists.sourceforge.net
To: Michael Rayment <mike@cs.mun.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IewAX-00081s-Ap
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 10:13:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IewAb-0000yy-88
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 10:13:30 -0700
In-Reply-To: <200710060219.20536.mike@cs.mun.ca>
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
--------------040802010503090109060209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Michael Rayment wrote:
> I just emerged the latest gentoo release of the nfs-utils package, 
> nfs-utils-1.1.0-r1.ebuild.  I found that the autofs code did not work for my 
> diskless computers that have a readonly /etc directory with a /etc/mtab 
> symbolically linked to /proc/mounts.  This was because the creation of the 
> mtab lock file /etc/mtab~nnnn failed.  I noticed that in the update_mtab() 
> function, a check was put in to acertain whether this situation existed and 
> silently carried on whereas the add_mtab() function did not perform the check 
> and consequently failed.  My simple minded fix was to add the the same check 
> to add_mtab() as can be seen in the context diff below.  Automounting worked 
> fine after the fix was applied.   Hopefully some fix will make its way into 
> the authoratative release so that I do not have to patch my code locally.

At first blush, this seems reasonable to me.  I assume you copied this 
logic from util-linux's mount command.  Does the umount.nfs command also 
suffer from this problem?  If it does, you should include a hunk to fix 
that as well.

To submit a patch for inclusion in nfs-utils, add a patch description 
(parts of the above paragraph will work) and a Signed-off-by: line, and 
send all of this with your diff in a text e-mail to neilb@suse.de, cc: 
nfs@lists.sourceforge.net.

> *** utils/mount/mount.c.sav     Sat Oct  6 01:52:21 2007
> --- utils/mount/mount.c Sat Oct  6 01:55:25 2007
> ***************
> *** 181,188 ****
> --- 181,191 ----
>                 update_mtab(ment.mnt_dir, &ment);
>                 return 0;
>         }
> 
> +       if (mtab_does_not_exist() || !mtab_is_writable())
> +               return 0;
> +
>         lock_mtab();
> 
>           if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
>                 fprintf(stderr, "Can't open " MOUNTED);

--------------040802010503090109060209
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


--------------040802010503090109060209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------040802010503090109060209
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040802010503090109060209--
