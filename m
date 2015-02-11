Return-Path: linux-fsdevel-owner@vger.kernel.org
Date: Wed, 11 Feb 2015 17:35:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>,
        xfs@oss.sgi.com
Subject: Re: [PATCH 16/20] xfs: pass a 64-bit count argument to
 xfs_iomap_write_unwritten
Message-ID: <20150211223522.GB28796@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-17-git-send-email-hch@lst.de>
 <20150129205232.GB11064@fieldses.org>
 <20150202073024.GA9399@lst.de>
 <20150202192404.GI6282@dastard>
 <20150202194300.GN6282@dastard>
 <20150202194826.GG22301@fieldses.org>
 <20150203183533.GA16929@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150203183533.GA16929@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 03, 2015 at 07:35:33PM +0100, Christoph Hellwig wrote:
> On Mon, Feb 02, 2015 at 02:48:26PM -0500, J. Bruce Fields wrote:
> > Previously: http://lkml.kernel.org/r/20150106175611.GA16413@lst.de
> > 
> > 	>       - any advice on testing?  Is there was some simple
> > 	>       virtual setup that would allow any loser with no special
> > 	>       hardware (e.g., me) to check whether they've broken the
> > 	>       block server?
> > 
> > 	Run two kvm VMs that share the same disk.  Create an XFS
> > 	filesystem on the MDS, and export it.  If the client has blkmapd
> > 	running (on Debian it needs to be started manually) it will use
> > 	pNFS for accessing the filesystem.  Verify that using the
> > 	per-operation counters in /proc/self/mounstats.  Repeat with
> > 	additional clients as nessecary.
> > 
> > 	Alternatively set up a simple iSCSI target using tgt or lio and
> > 	connect to it from multiple clients.
> > 
> > Which sounds reasonable to me, but I haven't tried to incorporate this
> > into my regression testing yet.
> 
> Additionally I can offer the following script to generate recalls,
> which don't really happen during normal operation.  I don't
> really know how to write a proper testcase that coordinates access
> to the exported filesystem and nfs unless it runs locally on the same node,
> though.  It would need some higher level, network aware test harness:

Thanks.  I got as far as doing a quick manual test with vm's sharing a
"disk":

	[root@f21-2]# mount -overs=4.1 f21-1:/exports/xfs-pnfs /mnt/
	[root@f21-2]# echo "hello world" >/mnt/testfile
	[root@f21-2]# grep LAYOUTGET /proc/self/mountstats 
		   LAYOUTGET: 1 1 0 236 196 0 4 4

I haven't tried to set up automated testing with recalls, but that
shouldn't be hard.

--b.

> 
> ----- snip -----
> #!/bin/sh
> 
> set +x
> 
> # wait for grace period
> touch /mnt/nfs1/foo
> 
> dd if=/dev/zero of=/mnt/nfs1/foo bs=128M count=32 conv=fdatasync oflag=direct &
> 
> sleep 2
> 
> echo "" > /mnt/test/foo && echo "recall done"
