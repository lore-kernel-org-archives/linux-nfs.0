From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Mon, 19 May 2008 22:47:34 -0400
Message-ID: <20080520024734.GA23457@fieldses.org>
References: <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org> <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com> <1210440728.12927.5.camel@localhost> <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com> <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com> <20080516195326.GD14228@fieldses.org> <CF603745-0163-469F-AC12-B4C5747038FC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "david m. richter" <richterd@gmail.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Manoj Naik <manoj@almaden.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754896AbYETCrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 22:47:43 -0400
In-Reply-To: <CF603745-0163-469F-AC12-B4C5747038FC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 18, 2008 at 11:22:18AM -0400, Chuck Lever wrote:
> On May 16, 2008, at 3:53 PM, J. Bruce Fields wrote:
>> On Sat, May 10, 2008 at 09:07:23PM -0400, david m. richter wrote:
>>> On Sat, May 10, 2008 at 7:50 PM, Chuck Lever  
>>> <chuck.lever@oracle.com> wrote:
>>>> On May 10, 2008, at 10:32 AM, Trond Myklebust wrote:
>>>>>
>>>>> On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
>>>>>>
>>>>>> Should you use in4_pton() instead?
>>>>>
>>>>> Can we rather convert this to use nfs_parse_server_address? We  
>>>>> don't
>>>>> need 10 different ways to parse text addresses...
>>>>
>>>> I'm OK with that, as long as there isn't a technical problem with  
>>>> using
>>>> in4_pton().
>>>
>>> nfs_parse_server_address() uses in4_pton(), it just also groks ipv6.
>>
>> This is all a bit orthogonal to the actual bug, as all those functions
>> want null-terminated strings too.
>>
>> We could apply the below (compile-tested only) and then add ipv6  
>> support
>> and converting to nfs_parse_server_address() in a subsequent patch.
>
> I'm looking at this code for other reasons, but it would be very easy to 
> teach nfs_parse_server_address() to take a string length and not assume 
> the passed-in address string is null-terminated.  Both in4_pton and 
> in6_pton will take a string length.

Whoops, I missed the srclen argument to in4_pton and in6_pton.

Though I just noticed it doesn't really matter much, since the
mountdata.hostname needs a null-terminated string.

--b.

commit 109f9a666db58e0511ac5a417e767027b148a9e0
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri May 9 15:10:56 2008 -0700

    nfs: Fix misparsing of nfsv4 fs_locations attribute
    
    The code incorrectly assumes here that the server name (or ip address)
    is null-terminated.  This can cause referrals to fail in some cases.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 5f9ba41..018292d 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -93,23 +93,6 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
 	return 0;
 }
 
-/*
- * Check if the string represents a "valid" IPv4 address
- */
-static inline int valid_ipaddr4(const char *buf)
-{
-	int rc, count, in[4];
-
-	rc = sscanf(buf, "%d.%d.%d.%d", &in[0], &in[1], &in[2], &in[3]);
-	if (rc != 4)
-		return -EINVAL;
-	for (count = 0; count < 4; count++) {
-		if (in[count] > 255)
-			return -EINVAL;
-	}
-	return 0;
-}
-
 /**
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
@@ -172,19 +155,20 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 
 		s = 0;
 		while (s < location->nservers) {
+			const struct nfs4_string *buf = &location->servers[s];
 			struct sockaddr_in addr = {
 				.sin_family	= AF_INET,
 				.sin_port	= htons(NFS_PORT),
 			};
+			u8 *ip = (u8 *)addr.sin_addr.s_addr;
 
-			if (location->servers[s].len <= 0 ||
-			    valid_ipaddr4(location->servers[s].data) < 0) {
-				s++;
-				continue;
-			}
+			if (buf->len <= 0 || buf->len >= PAGE_SIZE)
+				goto next;
+			if (!in4_pton(buf->data, buf->len, ip, '\0', NULL))
+				goto next;
 
-			mountdata.hostname = location->servers[s].data;
-			addr.sin_addr.s_addr = in_aton(mountdata.hostname),
+			mountdata.hostname = kmalloc(buf->len + 1, GFP_KERNEL);
+			mountdata.hostname[buf->len] = 0;
 			mountdata.addr = (struct sockaddr *)&addr;
 			mountdata.addrlen = sizeof(addr);
 
@@ -193,9 +177,11 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 					mountdata.mnt_path);
 
 			mnt = vfs_kern_mount(&nfs4_referral_fs_type, 0, page, &mountdata);
+			kfree(mountdata.hostname);
 			if (!IS_ERR(mnt)) {
 				break;
 			}
+next:
 			s++;
 		}
 		loc++;
