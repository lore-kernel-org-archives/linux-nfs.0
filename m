From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/17] RFC: proposed changes to the NFS mount
	command
Date: Mon, 16 Jul 2007 11:07:29 -0400
Message-ID: <469B89B1.1070201@oracle.com>
References: <20070716030150.11209.85724.stgit@manray.1015granger.net>
	<18074.61070.150991.554588@notabene.brown>
	<20070716080723.GA19783@infradead.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090107040807040600020800"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IASBL-0000mp-Ax
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:08:15 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IASBN-0006LT-Lo
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:08:19 -0700
In-Reply-To: <20070716080723.GA19783@infradead.org>
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
--------------090107040807040600020800
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Christoph Hellwig wrote:
> On Mon, Jul 16, 2007 at 02:05:34PM +1000, Neil Brown wrote:
>> I've wondered why that was happening... Can't we just make a version
>> x+1 with a big string buffer so new options get put there is regular
>> string format and old options stay the way they are?
>>
>> But I guess that - long term - it is better to be just like other
>> filesystems.
> 
> Having anything but a plain string means the filesystem is a complete
> oddball.  And with the planned removal of smbfs nfs would be the only
> oddball left.
> 
>>> option that will disable building nfsmount.c and nfs4mount.c, and
>>> enable building a version of these files that will introduce support
>>> for passing mount options as a string (that work is yet to be done).
>> Does this mean that you cannot compile nfs-utils to support both old
>> and new kernels?  Is that really a good plan?
>> What is the over-all migration strategy?
> 
> Making the different argument passing variants exclusive sounds like
> a bad idea indeed.

Yeah, Neil has convinced me that mount.nfs must support binary and 
string option processing simultaneously.

The 17 refactoring patches are still probably good clean ups overall.  I 
will leave them stand on their own merits.

--------------090107040807040600020800
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


--------------090107040807040600020800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090107040807040600020800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090107040807040600020800--
