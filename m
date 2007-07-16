From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: maintainership question about nfs-utils/util/mount
Date: Mon, 16 Jul 2007 12:25:41 -0400
Message-ID: <469B9C05.3000504@oracle.com>
References: <468EA263.5010909@oracle.com>
	<20070716114215.81e2ac37.jlayton@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040400040602000400080602"
Cc: NFS List <nfs@lists.sourceforge.net>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IATOq-0000tK-CE
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 09:26:16 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IATOr-0006ZJ-Hq
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 09:26:20 -0700
In-Reply-To: <20070716114215.81e2ac37.jlayton@redhat.com>
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
--------------040400040602000400080602
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Layton wrote:
> On Fri, 06 Jul 2007 16:13:23 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> I'm looking at nfs-utils/utils/mount in order to patch in support for 
>> passing a string of mount options to the kernel instead of an 
>> nfs_mount_data.
>>
>> In mount.c, main() invokes nfsmount() in nfsmount.c.  nfsmount() defines 
>> a structure on the stack called "data", then returns a pointer to "data" 
>> which is then passed to the kernel by main().
>>
>> I think the only way this continues to work is that there are three 1024 
>> character buffers defined in nfsmount()'s stack frame before "data," 
>> which places "data" far enough up the stack that subsequent function 
>> calls in main() don't smash it.
>>
>> Although this doesn't cause bad behavior today, it needs to be fixed to 
>> prevent future changes from breaking things badly.
>>
> 
> In the git tree I'm looking at, "data" is declared static. Does that protect
> it from getting smashed?

Yes.  For some reason, I missed that entirely the first time I looked at 
it.  Notice that nfs4_mount_data is also declared static in nfs4mount.c.

--------------040400040602000400080602
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


--------------040400040602000400080602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040400040602000400080602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040400040602000400080602--
