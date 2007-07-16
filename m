From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 04/17] mount.nfs: /bin/mount already handles
 --bind & friends
Date: Sun, 15 Jul 2007 23:57:54 -0400
Message-ID: <469AECC2.9000007@oracle.com>
References: <20070716031509.11209.35069.stgit@manray.1015granger.net>
	<18074.59805.866117.453406@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090703050904010607020003"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHip-0006BL-0J
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:58:07 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHir-0003fG-CF
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:58:10 -0700
In-Reply-To: <18074.59805.866117.453406@notabene.brown>
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
--------------090703050904010607020003
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Sunday July 15, chuck.lever@oracle.com wrote:
>> Clean-up: remove logic to handle --bind and other such options from
>> mount.nfs[4].
>>
>> These options are already handled in /bin/mount, and the logic for handling
>> them in the NFS helper is currently disabled.  Other helpers such as
>> mount.ocfs2 appear not to support --bind (ie. they rely on /bin/mount to
>> do it).
> 
> Fair enough - I don't suppose the protocol for how /bin/mount talks to
> /sbin/mount.$fstype is documented anywhere???  I guess just in the
> code :-(

There are rumors that somehow the helpers will turn into plug-ins one 
day.  But yes, this is ambiguous and somewhat crappy.  I did ask the 
developers who constructed mount.ocfs2 about this.

>> diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
>> index 19a7bf5..3e40841 100644
>> --- a/utils/mount/mount_constants.h
>> +++ b/utils/mount/mount_constants.h
>> @@ -39,6 +39,12 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
>>  #ifndef MS_VERBOSE
>>  #define MS_VERBOSE	0x8000	/* 32768 */
>>  #endif
>> +
>> +/* Custom mount options for our own purposes.  */
>> +#define MS_DUMMY	0x00000000
>> +#define MS_USERS	0x40000000
>> +#define MS_USER		0x80000000
>> +
>>  /*
>>   * Magic mount flag number. Had to be or-ed to the flag values.
>>   */
> 
> Hmmm.  That wasn't mentioned in the change-log, and I don't find it
> convincing.
> These flags are for internal use in mount.c so it makes lots of sense
> to define them in mount.c so that the definitions never leak.

Well, if we really wanted to be proper about this, we would include the 
mount_constants.c file from utils-linux instead of maintaining a local 
copy.  But since this is a local copy of the header, I figure that 
adding similar local definitions in here is OK.

I'll make a deeper dive on this to see if there's a better way to 
document this.

> Did you have a concrete reason for moving them?

Yes.  See the later patch that moves the mount system call to nfsmount.c 
and nfs4mount.c.  For some reason I don't recall, I thought it would be 
better to move these here in this patch, but that may have been ill-advised.

--------------090703050904010607020003
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


--------------090703050904010607020003
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090703050904010607020003
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090703050904010607020003--
