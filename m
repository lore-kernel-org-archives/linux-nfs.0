From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 8] knfsd: cleanups for exportfs code.
Date: Tue, 15 May 2007 17:15:57 +1000
Message-ID: <20070515170405.15621.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759454AbXEOHQi@vger.kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Neil Brown <neilb@suse.de>
Cc: shaggy@austin.ibm.com
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Following are 8 patches from Christoph Hellwig which tidy up the
"exportfs" code used by nfsd for communicating with filesystems about
the handling of filehandles.

One change of note is that the old "iget" approach to filehandle
lookup is moved out of generic code and into the two filesystems that
still use it (including jfs: hence the Cc to shaggy@austin.ibm.com).

These are for -mm until 2.6.23 opens.
NeilBrown



 [PATCH 001 of 8] knfsd: exportfs: add exportfs.h header
 [PATCH 002 of 8] knfsd: exportfs: remove iget abuse
 [PATCH 003 of 8] knfsd: exportfs: add procedural interface for NFSD
 [PATCH 004 of 8] knfsd: exportfs: remove CALL macro
 [PATCH 005 of 8] knfsd: exportfs: untangle ISDIR logic in find_exported_dentry
 [PATCH 006 of 8] knfsd: exportfs: move acceptable check into find_acceptable_alias
 [PATCH 007 of 8] knfsd: exportfs: add find_disconnected_root helper
 [PATCH 008 of 8] knfsd: exportfs: split out reconnecting a dentry from find_exported_dentry.
