From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Properly ignore quota options
Date: Wed, 18 Jul 2007 13:23:47 -0400
Message-ID: <469E4CA3.5030106@oracle.com>
References: <20070718170931.GA30174@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030307070804030902090902"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBDHA-0008K4-Rw
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 10:25:24 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBDHE-0007fB-DR
	for nfs@lists.sourceforge.net; Wed, 18 Jul 2007 10:25:28 -0700
In-Reply-To: <20070718170931.GA30174@uio.no>
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
--------------030307070804030902090902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> Hi,
> 
> Now that NFS mounting has been taken over by nfs-utils, it seems like I've
> gotten a few bugs on my hands. The included patch is based on a user
> suggestion from about a year ago. It would be great if someone could also
> check out these two bugs:
> 
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=301955
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=301953

My review of the utils/mount source code also suggests that background 
mounting is not working at all in mount.nfs.  I'm thinking this is 
something that should be addressed before we get to the string-ified 
mount option support.  I included a patch in my recent clean-up series 
that might help get BG working again (similar in nature to your umount 
return code patch).

But I suspect that there is more to do here.  I haven't studied how the 
background mount process is forked... I suspect mount.nfs is relying on 
/bin/mount to do it.

I'm happy to track this down and submit some fixes for consideration.

[ patch to ignore quota-related mount options snipped...
   looks OK to me ]

--------------030307070804030902090902
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


--------------030307070804030902090902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------030307070804030902090902
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030307070804030902090902--
