From: Steve Dickson <SteveD@redhat.com>
Subject: Readdirplus compatibility fix for IRIX server
Date: Wed, 10 Dec 2003 17:48:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FD7A2A1.1030109@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050201000804060500010603"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUD6r-00040T-AT
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 14:47:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUD6q-0003vM-IQ
	for nfs@lists.sourceforge.net; Wed, 10 Dec 2003 14:47:08 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------050201000804060500010603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey Trond,

There is a compatibly issue with the linux-2.4.X-X-rdplus.dif
patch on your website and IRIX servers.

The scenario is:

mount irix:/server /mnt/irix
cd /mnt/irix;
mkdir dir; touch dir/file;
rm -rf dir # fails with an -525 error code (ETOOSMALL)

The problem happens when nfs_readdir() sends an "old"
cookie  (via uncached_readdir())

        res = readdir_search_pagecache(desc);
        if (res == -EBADCOOKIE) {
            /* This means either end of directory */
            if (desc->entry->cookie != desc->target) {
                /* Or that the server has 'lost' a cookie */
                res = uncached_readdir(desc, dirent, filldir);
                if (res >= 0)
                    continue;
            }

It seems IRIX servers fails READDIRPLUS calls with
NFSERR_TOOSMALL when the cookie does not exist which
is *not* the case with "normal" READDIR calls...
Cute uh...

Now one way to handle this is to simply ignore this
error case..
            if (res == -EIO)
                desc->error = 0;

since uncached_readdir() will always return -EIO when
the RPC call fails (which does work)....

But I got to wondering.... why is that last readdir RPC
even needed when the server *has* already set the EOF bit?

Since the server is telling client there is no more data,
is there really a need for that final readdir RPC? Now
if there is a cookie mismatch and the EOF bit is not set
then I (guess) can see the need for another RPC... But in the
"normal" case it appears that extra RPC is not needed....
(Note: This extra RPC happens with both READDIR and READDIRPLUSs
it does affect the stock kernels and it seems to happen with
non-linux servers, like netapp and IRIX)

The attached patch eliminates the extra RPC (when not
needed) which in turn takes care of the IRIX incompatibly
problem....

Comments?

SteveD.

--------------050201000804060500010603
Content-Type: text/plain;
 name="linux-2.4.22-nfs-readdirplus-irix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.22-nfs-readdirplus-irix.patch"

--- linux-2.4.22/fs/nfs/dir.c.org	2003-12-09 14:21:59.000000000 -0500
+++ linux-2.4.22/fs/nfs/dir.c	2003-12-10 16:49:28.000000000 -0500
@@ -431,7 +431,8 @@ static int nfs_readdir(struct file *filp
 		res = readdir_search_pagecache(desc);
 		if (res == -EBADCOOKIE) {
 			/* This means either end of directory */
-			if (desc->entry->cookie != desc->target) {
+			if (desc->entry->eof == 0 &&
+				desc->entry->cookie != desc->target) {
 				/* Or that the server has 'lost' a cookie */
 				res = uncached_readdir(desc, dirent, filldir);
 				if (res >= 0)

--------------050201000804060500010603--



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
