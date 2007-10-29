From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 18/27] NFS: Prevent nfs_getattr() hang during
 heavy write	workloads
Date: Mon, 29 Oct 2007 11:44:38 -0400
Message-ID: <4725FFE6.2030000@oracle.com>
References: <20071026173213.31475.72792.stgit@manray.1015granger.net>
	<EXNANE017zynrvDOv5y00000824@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090908070306000707060804"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImWog-0005su-C1
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 08:46:14 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImWoj-0008Bg-CZ
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 08:46:20 -0700
In-Reply-To: <EXNANE017zynrvDOv5y00000824@exnane01.hq.netapp.com>
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
--------------090908070306000707060804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> Can you expound a little on whether holding a mutex across the
> nfs_wb_nocommit() call is safe?   In the hard-mount non-interruptible
> case, isn't it possible that the writeback will take an unbounded time?

Without this change, nfs_wb_nocommit() will wait forever anyway in that 
case.  As applications continue queuing writes to that inode, eventually 
the mount point's bdi congestion logic kicks in and user space is forced 
to wait for that file as well.

With the change, the i_mutex prevents new application writes.  User 
space will stop and wait sooner, but the end result is the same.

> At 01:32 PM 10/26/2007, Chuck Lever wrote:
>> POSIX requires that ctime and mtime, as reported by the stat(2) call,
>> reflect the activity of the most recent write(2).  To that end, nfs_getattr()
>> flushes pending dirty writes to a file before doing a GETATTR to allow the
>> NFS server to set the file's size, ctime, and mtime properly.
>>
>> However, nfs_getattr() can be starved when a constant stream of application
>> writes to a file prevents nfs_wb_nocommit() from completing.  This usually
>> results in hangs of programs doing a stat against an NFS file that is being
>> written.  "ls -l" is a common victim of this behavior.
>>
>> To prevent starvation, hold the file's i_mutex in nfs_getattr() to
>> freeze applications writes temporarily so the client can more quickly obtain
>> clean values for a file's size, mtime, and ctime.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/inode.c |   13 +++++++++++--
>> 1 files changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index cd0e57f..cc3a09d 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -461,9 +461,18 @@ int nfs_getattr(struct vfsmount *mnt, struct 
>> dentry *dentry, struct kstat *stat)
>> 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
>> 	int err;
>>
>> -	/* Flush out writes to the server in order to update c/mtime */
>> -	if (S_ISREG(inode->i_mode))
>> +	/*
>> +	* Flush out writes to the server in order to update c/mtime.
>> +	*
>> +	* Hold the i_mutex to suspend application writes temporarily;
>> +	* this prevents long-running writing applications from blocking
>> +	* nfs_wb_nocommit.
>> +	*/
>> +	if (S_ISREG(inode->i_mode)) {
>> +		mutex_lock(&inode->i_mutex);
>> 		nfs_wb_nocommit(inode);
>> +		mutex_unlock(&inode->i_mutex);
>> +	}
>>
>> 	/*
>> 	* We may force a getattr if the user cares about atime.
>>
>>
>> -------------------------------------------------------------------------
>> This SF.net email is sponsored by: Splunk Inc.
>> Still grepping through log files to find problems?  Stop.
>> Now Search log events and configuration files using AJAX and a browser.
>> Download your FREE copy of Splunk now >> http://get.splunk.com/
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs

--------------090908070306000707060804
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


--------------090908070306000707060804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------090908070306000707060804
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090908070306000707060804--
