From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/17] RFC: proposed changes to the NFS mount
	command
Date: Mon, 16 Jul 2007 11:03:43 -0400
Message-ID: <469B88CF.8040009@oracle.com>
References: <20070716030150.11209.85724.stgit@manray.1015granger.net>
	<18074.61070.150991.554588@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070702060902000605080602"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAS7b-0008Sp-DS
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:04:23 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAS7d-0001gS-Kv
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:04:27 -0700
In-Reply-To: <18074.61070.150991.554588@notabene.brown>
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
--------------070702060902000605080602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Sunday July 15, chuck.lever@oracle.com wrote:
>> Hi Neil-
>>
>> I've got a series of patches to the NFS mount command that prepare it
>> for using a C string to pass mount options to the kernel, rather than
>> a binary nfs_mount_data structure.
> 
> I've wondered why that was happening... Can't we just make a version
> x+1 with a big string buffer so new options get put there is regular
> string format and old options stay the way they are?
> 
> But I guess that - long term - it is better to be just like other
> filesystems.
> 
> 
>> The goal of these clean-ups is to allow the creation of a ./configure
>> option that will disable building nfsmount.c and nfs4mount.c, and
>> enable building a version of these files that will introduce support
>> for passing mount options as a string (that work is yet to be done).
> 
> Does this mean that you cannot compile nfs-utils to support both old
> and new kernels?  Is that really a good plan?
> What is the over-all migration strategy?

The NFS client string mount option support is destined for 2.6.23.

My plan was to build for either binary mount options or string mount 
options, switched via a ./configure option.  But it's a good point that 
currently, the mount command will support all versions of 
nfs_mount_data, so it should probably support binary and string options 
simultaneously too.

I will reconsider my design.  Thanks for the useful feedback.

>> They certainly need some testing yet, but can you take a look at these
>> and tell me if they are generally acceptable or if I need to take a
>> different direction?  Hopefully they are straightforward and won't take
>> much of your time.
> 
> Some of these are obviously good cleanups.  Would it inconvenience you
> if I just picked off the ones I like for now and leave you to rebase?

I would like to do some testing, and maybe some review from others on 
the list (hint hint cough).  Can you let me know (offline) which ones 
you want to take, and I will test those first?

--------------070702060902000605080602
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


--------------070702060902000605080602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------070702060902000605080602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070702060902000605080602--
