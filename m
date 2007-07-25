From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: have string-based mount options default to "intr"
	mounts
Date: Wed, 25 Jul 2007 15:48:24 -0400
Message-ID: <46A7A908.3080906@oracle.com>
References: <20070725145614.e17ca721.jlayton@redhat.com>	<46A7A632.2050900@oracle.com>
	<20070725154107.063c3b9a.jlayton@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090404040502010406090008"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070725154107.063c3b9a.jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------090404040502010406090008
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Layton wrote:
> On Wed, 25 Jul 2007 15:36:18 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> I thought "nointr" was the default because it is safest.
>>
> 
> I could see maybe with soft mounts, but in conjunction with a hard
> mount (which is the default) is there danger of corruption?

If you hit ^C during a multi-segment write, I believe there is the 
possibility of data corruption.

>> Jeff Layton wrote:
>>> The current string-based mount options default to "nointr" mounts. This
>>> is consistent with the current behavior of the struct-based mount
>>> options for NFSv2/3, but inconsistent with v4.
>>>
>>> I've just sent a nfs-utils patch to make the default be "intr" for all
>>> NFS flavors. This patch makes the default the same when using
>>> string-based mount options.
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index b2a851c..55f9b8b 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -1122,7 +1122,9 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
>>>  		char *c;
>>>  		int status;
>>>  		struct nfs_parsed_mount_data args = {
>>> -			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
>>> +			.flags		= (NFS_MOUNT_INTR |
>>> +					   NFS_MOUNT_VER3 |
>>> +					   NFS_MOUNT_TCP),
>>>  			.rsize		= NFS_MAX_FILE_IO_SIZE,
>>>  			.wsize		= NFS_MAX_FILE_IO_SIZE,
>>>  			.timeo		= 600,
>>> @@ -1608,6 +1610,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
>>>  	default: {
>>>  		unsigned int len;
>>>  		struct nfs_parsed_mount_data args = {
>>> +			.flags		= NFS4_MOUNT_INTR,
>>>  			.rsize		= NFS_MAX_FILE_IO_SIZE,
>>>  			.wsize		= NFS_MAX_FILE_IO_SIZE,
>>>  			.timeo		= 600,
>>> _______________________________________________
>>> NFSv4 mailing list
>>> NFSv4@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> 
> 

--------------090404040502010406090008
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


--------------090404040502010406090008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------090404040502010406090008--
