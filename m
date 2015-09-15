Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19619 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbIORPI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 13:15:08 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFSv4 security negotiation issue
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <019501d0efd4$401f4240$c05dc6c0$@mindspring.com>
Date: Tue, 15 Sep 2015 13:15:03 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E19B018D-1578-4964-B29F-FC7BF361F977@oracle.com>
References: <7A550B5E-9EAB-4431-BBBA-1C77EE86539F@oracle.com> <019501d0efd4$401f4240$c05dc6c0$@mindspring.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 15, 2015, at 12:33 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:

>> We've found an unexpected behavior with mount security negotiation in the
>> current Linux NFS client.
>> 
>> Given two real shares on an NFS server: one is a sys-only share, and the
>> other is a krb5-only share. When we try to mount the sys-only share
> without
>> specifying a sec= option, it fails. Specifying sec=sys is successful.
>> 
>> What is seen on the wire:
>> 
>> 1. The client attempts to access the pseudofs, and negotiates
>> krb5
>> 
>> 2. The client walks down the pseudofs namespace to the sys-only share
>> 
>> 3. The client attempts to access the sys-only share with krb5 and gets
>> WRONGSEC
>> 
>> 4. The client negotiates sys, and continues setting up the mount
>> 
>> 5. nfs_fs_mount_common() invokes nfs_get_root(), but it uses the
>> pseudofs superblock, so it does a GETATTR on the share's root directory
> with
>> krb5, and that fails
>> 
>> At this point the client gives up, and the mount attempt fails.
>> 
>> We could alter the server to allow a GETATTR with the same flavor as the
>> underlying directory. But seems like the problem is on the client: it
> should
>> use the negotiated flavor that is appropriate to the share, not the flavor
>> appropriate for the pseudofs.
>> 
>> Any thoughts?
> 
> Hmm, I thought maybe this was a scenario I had not tested, but I think I'm
> misunderstanding the sequence. Could you summarize the ops and response for
> each COMPOUND request?

There are two shares on the server.

The share being mounted is /export/CTHON. It is a sys-only
share. No "sec=" option is used on the mount command. The
expected outcome is that the mount will succeed and use
sec=sys.

The share that is not being mounted here is /export/KRB5.
It is shared with at least krb5i, which means the set of
flavors the server accepts for the pseudofs includes
both krb5i and sys.

The client has already negotiated krb5i to access the
pseudofs. I see a PUTROOTFH using krb5i and it is
successful. The negotiation is not in the trace I have.

I see a number of GETATTRs then a LOOKUP /export, all with
krb5i, all successful.

Using krb5i, LOOKUP /CTHON, which fails with WRONGSEC.

Client recovers with SECINFO on /CTHON using krb5i. The
server responds with a list containing just AUTH_UNIX.

Client tries the LOOKUP /CTHON again, now with sys. It
works.

Similar GETATTR activity using sys as the client mounts
this share.

Then one last GETATTR, this time using krb5i. The FH is
the /export/CTHON directory. This fails with WRONGSEC.

The attr mask here is Supported Attrs, FH_Expire_type,
Link_Support, Symlink_Support, ACLSupport. This is
from nfs4_server_capabilities(), which is invoked only
in nfs4_proc_get_rootfh() and nfs4_proc_get_root().

The next operation OTW is a RENEW that happens a minute
later.

--
Chuck Lever



