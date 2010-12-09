Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:37749 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216Ab0LIKMx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 05:12:53 -0500
Message-ID: <4D00AB9F.3030808@canonical.com>
Date: Thu, 09 Dec 2010 11:12:47 +0100
From: Stefan Bader <stefan.bader@canonical.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 24302] Kernel crashes when repeatedly trying to mount nfs
 share that is failing
References: <bug-24302-104@https.bugzilla.kernel.org/> <201012081830.oB8IUZ4t027387@demeter2.kernel.org> <1291835010.3067.4.camel@heimdal.trondhjem.org> <3F9D016C-9EDF-4B65-AD77-F225D5F1FA66@oracle.com> <A205A7F2-6E7C-4129-BC3A-D2AE5E38DFE6@oracle.com>
In-Reply-To: <A205A7F2-6E7C-4129-BC3A-D2AE5E38DFE6@oracle.com>
Content-Type: multipart/mixed;
 boundary="------------060104000503090900040403"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------060104000503090900040403
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 12/09/2010 01:19 AM, Chuck Lever wrote:
> Hi Stefan-
> 
> On Dec 8, 2010, at 3:35 PM, Chuck Lever wrote:
> 
>> 
>> On Dec 8, 2010, at 2:03 PM, Trond Myklebust wrote:
>> 
>>> On Wed, 2010-12-08 at 18:30 +0000, bugzilla-daemon@bugzilla.kernel.org 
>>> wrote:
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=24302
>>>> 
>>>> 
>>>> Andrew Morton <akpm@linux-foundation.org> changed:
>>>> 
>>>> What    |Removed                     |Added 
>>>> ----------------------------------------------------------------------------
>>>>
>>>> 
Component|Other                       |NFS
>>>> AssignedTo|fs_other@kernel-bugs.osdl.o |trond.myklebust@fys.uio.no |rg
>>>> |
>>>> 
>>>> 
>>>> 
>>>> 
>>>> --- Comment #8 from Andrew Morton <akpm@linux-foundation.org>
>>>> 2010-12-08 18:30:32 --- OK, I reassigned it to NFS.  If that was wrong
>>>> then at least the NFS guys should be able to help point things in the
>>>> right direction.
>>> 
>>> <Switching to email interface. Please do not edit the bugzilla entry 
>>> directly, since that will lose the above Cc information>

Missed to read the above, so I have to duplicate things a bit, sorry. Removed
the bugzilla cc, so the report does not get spammed.

>>> 
>>> 
>>> Chuck,
>>> 
>>> Stefan appears to be hitting a panic in the nfs_umount() call from 
>>> nfs_walk_authlist(). Can you take a look, please?
>> 
>> Recv'd.  I'll have a look.
> 
> Apologies in advance for the attachment.  There are a few other clean ups
> that can be done, but this seems to be the minimal fix.  Please try this and
> let us know if it addresses your panic.
> 
> 
> 
> 
> 
> 
> The faulty commit went in a while back, so this patch is probably appropriate
> for stable kernels (back to 2.6.31, where this was likely introduced).
> 

I can confirm that this was the root cause of the crash. The sha referenced as
the causing commit, got in with a 2.6.32-rc so I added the stable info
accordingly. I also added my tested-by and slightly modified the bug reference
format (Chuck, I hope this is ok).

-Stefan

--------------060104000503090900040403
Content-Type: text/x-diff;
 name="0001-NFS-Fix-panic-after-nfs_umount.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-NFS-Fix-panic-after-nfs_umount.patch"

>From dcc0a9d5d9490680ea9faa7b90de3224c3aba7e3 Mon Sep 17 00:00:00 2001
From: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 8 Dec 2010 19:07:12 -0500
Subject: [PATCH] NFS: Fix panic after nfs_umount()

After a few unsuccessful NFS mount attempts in which the client and
server cannot agree on an authentication flavor both support, the
client panics.  nfs_umount() is invoked in the kernel in this case.

Turns out this particular UMNT RPC invocation causes the RPC client to
write off the end of the rpc_clnt's iostat array.  This is because the
mount client's nrprocs field is initialized with the count of defined
procedures (two: MNT and UMNT), rather than the size of the client's
proc array (four).

The fix is to use the same initialization technique used by most other
upper layer clients in the kernel.

Introduced by commit 0b524123, which failed to update nrprocs when it
added support for UMNT.

BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=24302
BugLink: http://bugs.launchpad.net/bugs/683938

Reported-by: Stefan Bader <stefan.bader@canonical.com>
Tested-by: Stefan Bader <stefan.bader@canonical.com>
CC: stable@kernel.org # >= 2.6.32
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/mount_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 59047f8..50552c5 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -503,13 +503,13 @@ static struct rpc_procinfo mnt3_procedures[] = {
 
 static struct rpc_version mnt_version1 = {
 	.number		= 1,
-	.nrprocs	= 2,
+	.nrprocs	= ARRAY_SIZE(mnt_procedures),
 	.procs		= mnt_procedures,
 };
 
 static struct rpc_version mnt_version3 = {
 	.number		= 3,
-	.nrprocs	= 2,
+	.nrprocs	= ARRAY_SIZE(mnt_procedures),
 	.procs		= mnt3_procedures,
 };
 
-- 
1.7.0.4


--------------060104000503090900040403--
