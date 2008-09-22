From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 13:29:01 -0400
Message-ID: <1222104541.7615.23.camel@localhost>
References: <20080905191939.GG22796@merfinllc.com>
	 <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com>
	 <20080911184951.GB19054@merfinllc.com> <200809221805.48463.hpj@urpla.net>
	 <1222101322.7615.6.camel@localhost>  <20080922170414.GC12483@merfinllc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-is3cApJkYlRsaw3Ok6RD"
Cc: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>, linux-kernel@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56002 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbYIVR3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2008 13:29:08 -0400
In-Reply-To: <20080922170414.GC12483-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-is3cApJkYlRsaw3Ok6RD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2008-09-22 at 10:04 -0700, Aaron Straus wrote:
> Here is the crux.  It was possible previously but unlikely e.g. our app
> never saw this behavior.  The new writeout semantics causes visible
> holes in files often.
> 
> Anyway, I agree the new writeout semantics are allowed and possibly
> saner than the previous writeout path.  The problem is that it is
> __annoying__ for this use case (log files).

There is always the option of using syslog.

> I'm not sure if there is an easy solution.  We want the VM to writeout
> the address space in order.   Maybe we can start the scan for dirty
> pages at the last page we wrote out i.e. page 0 in the example above?

You can never guarantee that in a multi-threaded environment.

Two threads may, for instance, force 2 competing fsync() calls: that
again may cause out-of-order writes.
...and even if the client doesn't reorder the writes, the _server_ may
do it, since multiple nfsd threads may race when processing writes to
the same file.

Anyway, the patch to force a single threaded nfs client to write out the
data in order is trivial. See attachment...

Trond

--=-is3cApJkYlRsaw3Ok6RD
Content-Disposition: attachment; filename=linux-2.6.27-ordered_writes.dif
Content-Type: message/rfc822; name=linux-2.6.27-ordered_writes.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: 
NFS: Always sync data to disk in sequential order
Subject: No Subject
Message-Id: <1222104509.7615.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3229e21..eb6b211 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1428,7 +1428,8 @@ static int nfs_write_mapping(struct address_space *mapping, int how)
 		.sync_mode = WB_SYNC_NONE,
 		.nr_to_write = LONG_MAX,
 		.for_writepages = 1,
-		.range_cyclic = 1,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
 	};
 	int ret;
 

--=-is3cApJkYlRsaw3Ok6RD--

