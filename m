Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:48507 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396Ab3CSQ4w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 12:56:52 -0400
Message-ID: <514898C0.8050101@canonical.com>
Date: Tue, 19 Mar 2013 11:56:32 -0500
From: Dave Chiluk <dave.chiluk@canonical.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 setattr null-terminates strings
References: <513A1BD1.6060709@canonical.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B6F80@sacexcmbx05-prd.hq.netapp.com>
Content-Type: multipart/mixed;
 boundary="------------000604000908090000020408"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000604000908090000020408
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 03/08/2013 12:33 PM, Myklebust, Trond wrote:
> On Fri, 2013-03-08 at 11:11 -0600, Dave Chiluk wrote:
>> As of commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172, the SETATTR nfsv4
>> command now null terminates fattr_owner and fattr_owner_group.
>>
>> Here is an example excerpt from a tcpdump
>> Opcode: SETATTR (34)
>>     stateid
>>         [StateID Hash: 0xafa9]
>>         seqid: 0x00000000
>>         Data: 000000000000000000000000
>>     obj_attributes
>>         attrmask
>>             recc_attr: FATTR4_OWNER_GROUP (37)
>>                 fattr4_owner_group: groupname@domainname.com
>>                     length: 25
>>
>> This means that even though there are actually 24 characters in
>> groupname@domainname.com, we now send 24 characters + 1 null character.
>> Hence the total length of 25.  Previously the client would send just the
>> 24 characters and set length to 24.
>>
>> This isn't an issue for communication with other Linux machines, but it
>> is an issue for interaction with AIX machines.  As is discussed here.
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1101292
>>
>> I attempted to read the RFC available here
>> http://tools.ietf.org/html/rfc5661, but have not been able to find a
>> statement instructing one way or the other.
>>
>> So the question becomes, is it correct for linux to be sending this null
>> terminator when read against the RFC, or is it AIX's responsibility to
>> handle null-terminated strings?
> 
> The client is definitely in error here according to RFC3530. Please
> check if the attached patch fixes the issue for you.
> 
> Cheers
>   Trond
> 

Thanks again for the patch.  When will this get pushed upstream?  I'm
blocked by the upstream commit, since I don't want to pull this in as a
SAUCE patch.

Dave.

--------------000604000908090000020408
Content-Type: text/x-patch;
 name="0001-NFSv4-Fix-the-string-length-returned-by-the-idmapper.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-NFSv4-Fix-the-string-length-returned-by-the-idmapper.pa";
 filename*1="tch"

>From 90eabc5dfde58de5c37de3866f427da02e86ce17 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 8 Mar 2013 12:56:37 -0500
Subject: [PATCH] NFSv4: Fix the string length returned by the idmapper

Functions like nfs_map_uid_to_name() and nfs_map_gid_to_group() are
expected to return a string without any terminating NUL character.
Regression introduced by commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172
(NFS: Store the legacy idmapper result in the keyring).

Reported-by: Dave Chiluk <dave.chiluk@canonical.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
Cc: stable@vger.kernel.org [>=3.4]
---
 fs/nfs/idmap.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index dc0f98d..c516da5 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -726,9 +726,9 @@ out1:
 	return ret;
 }
 
-static int nfs_idmap_instantiate(struct key *key, struct key *authkey, char *data)
+static int nfs_idmap_instantiate(struct key *key, struct key *authkey, char *data, size_t datalen)
 {
-	return key_instantiate_and_link(key, data, strlen(data) + 1,
+	return key_instantiate_and_link(key, data, datalen,
 					id_resolver_cache->thread_keyring,
 					authkey);
 }
@@ -738,6 +738,7 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
 		struct key *key, struct key *authkey)
 {
 	char id_str[NFS_UINT_MAXLEN];
+	size_t len;
 	int ret = -ENOKEY;
 
 	/* ret = -ENOKEY */
@@ -747,13 +748,15 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
 	case IDMAP_CONV_NAMETOID:
 		if (strcmp(upcall->im_name, im->im_name) != 0)
 			break;
-		sprintf(id_str, "%d", im->im_id);
-		ret = nfs_idmap_instantiate(key, authkey, id_str);
+		/* Note: here we store the NUL terminator too */
+		len = sprintf(id_str, "%d", im->im_id) + 1;
+		ret = nfs_idmap_instantiate(key, authkey, id_str, len);
 		break;
 	case IDMAP_CONV_IDTONAME:
 		if (upcall->im_id != im->im_id)
 			break;
-		ret = nfs_idmap_instantiate(key, authkey, im->im_name);
+		len = strlen(im->im_name);
+		ret = nfs_idmap_instantiate(key, authkey, im->im_name, len);
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.8.1.4


--------------000604000908090000020408--
