Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:46761 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757714Ab3LBU2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 15:28:53 -0500
Message-ID: <529CEBC3.8060505@pingtimeout.net>
Date: Mon, 02 Dec 2013 22:21:23 +0200
From: =?ISO-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: bfields@fieldses.org
CC: linux-nfs@vger.kernel.org
Subject: Patch for mapping EILSEQ into NFSERR_INVAL
Content-Type: multipart/mixed;
 boundary="------------060306060709040602020102"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060306060709040602020102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

NTFS file system and some other filesystems seem to return EILSEQ when 
user passes badly formatted data. Current NFSv4 implementation does not 
map EILSEQ into any known NFSv4 error code which causes problems in some 
use cases. In my case I observed that if filesystem returns EILSEQ, the 
NFS share will begin I/O erroring until it's able to recover (If there 
are handles open to the files in the share, I/O errors will continue 
until they are closed after which the share recovers after small period 
of time).

Given that widely used ntfs-3g FUSE module also returns EILSEQ on the 
same case (I tested this) I would argue that a fix should be done for 
upstream especially since RFC5661 clearly defines that invalid UTF-8 
sequence should map into NFSERR_INVAL, exact quote: "Where the client 
sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL 
(see Table 5)".

Other way of fixing this would be to change all EILSEQs to return 
something else but I think this is a wrong way to fix the problem since 
it takes the sane error message away (Invalid or incomplete multibyte or 
wide character).

If we simply do a mapping here then isn't the fix straightforward 
(attached)?

BR, Antti

--------------060306060709040602020102
Content-Type: text/plain; charset=windows-1252;
 name="proposed_mapping.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="proposed_mapping.patch"

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 54c6b3d..a022a23 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -724,6 +724,7 @@ nfserrno (int errno)
                { nfserr_notdir, -ENOTDIR },
                { nfserr_isdir, -EISDIR },
                { nfserr_inval, -EINVAL },
+               { nfserr_inval, -EILSEQ },
                { nfserr_fbig, -EFBIG },
                { nfserr_nospc, -ENOSPC },
                { nfserr_rofs, -EROFS },

--------------060306060709040602020102--
