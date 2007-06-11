From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/5] locks: rename lease functions to reflect locks.c conventions
Date: Mon, 11 Jun 2007 12:53:13 -0400
Message-ID: <20070611165313.GB9135@fieldses.org>
References: <OFACAF92E2.7AA61B28-ON882572F5.005CD6AC-882572F5.005CFA2E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <OFACAF92E2.7AA61B28-ON882572F5.005CD6AC-882572F5.005CFA2E@us.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Jun 09, 2007 at 09:56:29AM -0700, Marc Eshel wrote:
> We need to export vfs_lease so nfsd can call it.

Oops, thanks for finding that--done.--b.

--b.

diff --git a/fs/locks.c b/fs/locks.c
index 82ac90b..c2fd0a5 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1453,6 +1453,8 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 	return error;
 }
 
+EXPORT_SYMBOL_GPL(vfs_setlease);
+
 /**
  *	fcntl_setlease	-	sets a lease on an open file
  *	@fd: open file descriptor
