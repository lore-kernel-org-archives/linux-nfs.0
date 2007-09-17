From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] export man page updated.
Date: Mon, 17 Sep 2007 12:46:09 -0400
Message-ID: <46EEAF51.5010400@oracle.com>
References: <46EE9E73.1070002@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070809010608080701010907"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXJkL-0003F9-5O
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:46:53 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IXJkO-0006yp-Ny
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:46:58 -0700
In-Reply-To: <46EE9E73.1070002@RedHat.com>
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
--------------070809010608080701010907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> It was pointed that the exportfs man page talks about
> the wrong file. In 2.6 kernels the export information
> is now kept in /var/lib/nfs/etab not /var/lib/nfs/xtab.
> 
> This patch basically does a 's/xtab/etab' and is relative
> to the to the Fedora git tree
> 
> git://git.infradead.org/~steved/nfs-utils.fedora

Hrm, an attachment.

@@ -93,8 +93,8 @@ file, so that only default options and options given 
on the command
  line are used.
  .TP
  .B -r
-Reexport all directories. It synchronizes /var/lib/nfs/xtab
-with /etc/exports. It removes entries in /var/lib/nfs/xtab
+Reexport all directories. It synchronizes /var/lib/nfs/etab
+with /etc/exports. It removes entries in /var/lib/nfs/etab
  which are deleted from /etc/exports, and remove any entries from the
  kernel export table which are no longer valid.
  .TP

In this hunk, why isn't the file name bold, like the others?

--------------070809010608080701010907
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


--------------070809010608080701010907
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------070809010608080701010907
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070809010608080701010907--
