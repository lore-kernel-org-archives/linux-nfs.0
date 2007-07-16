From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Fix umount.nfs exit status
Date: Mon, 16 Jul 2007 13:07:08 -0400
Message-ID: <469BA5BC.2040100@oracle.com>
References: <20070714091848.GA23409@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070906030004000109060508"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAU52-0005Kf-VP
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 10:09:53 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAU55-0004op-BU
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 10:09:56 -0700
In-Reply-To: <20070714091848.GA23409@uio.no>
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
--------------070906030004000109060508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steinar-

Steinar H. Gunderson wrote:
> Hi,
> 
> As per a bug report from a user:
> 
> mount.c seems to assume that nfsumount() uses standard C true/false
> return values, and inverts them for the exit status (where 0 is
> traditionally considered success). However, nfsumount() consistently
> seems to use 0 for success, and thus a success gets returned as exit
> status 1 and a failure as exit status 0. This confuses at least
> the GNOME drive manager applet, and probably others as well.
> 
> Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
> 
> Index: nfs-utils-1.1.0/utils/mount/mount.c
> ===================================================================
> --- nfs-utils-1.1.0.orig/utils/mount/mount.c
> +++ nfs-utils-1.1.0/utils/mount/mount.c
> @@ -371,7 +371,7 @@ int main(int argc, char *argv[])
>                         umount_usage();
>                         exit(1);
>                 }
> -               exit(nfsumount(argc, argv) ? 0 : 1);
> +               exit(nfsumount(argc, argv));
>         }
> 
>         if(argv[1] && argv[1][0] == '-') {
> 
> /* Steinar */

Reviewing the NFS umount return path, I see other problems:

1.  nfsumount.c does not contain the string "EX_" which means it doesn't 
use the normal mount error return codes (and it probably should?).  For 
example, del_mtab() should return EX_FILEIO on error.  The use of 
improper umount options should return EX_USAGE.  A failure or negative 
result of the MNT RPC call should return EX_FAIL.

2.  _nfsumount returns an integer result which is ignored by it's only 
caller.  If the result truly doesn't matter (which I doubt), then 
_nfsumount should return void; otherwise the caller should be fixed to 
return _nfsumount's return code.

3.  nfs_call_umount returns an integer, but appears to be confused about 
whether one is success or zero is success.  In fact, it returns the 
value of "res" which is an enum clnt_stat, not a valid mount return code.

4.  There is one place where nfsumount.c needlessly uses exit(1) instead 
of returning.

I agree with removing the logic you eliminated, but more needs to be 
done in nfsumount.c to make this a complete fix.

--------------070906030004000109060508
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


--------------070906030004000109060508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070906030004000109060508
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070906030004000109060508--
