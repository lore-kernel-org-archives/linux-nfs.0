From: cel@citi.umich.edu (Chuck Lever)
Subject: [PATCH 0/2] RFC: exporting per-superblock statistics to user space
Date: Thu, 17 Mar 2005 11:26:11 -0500 (EST)
Message-ID: <20050317162611.6F2741BB95@citi.umich.edu>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

 We still have a need to provide "iostat" like statistics for NFS
 clients.  Following are a couple of patches, against 2.6.11.3, which
 prototype an approach for providing this kind of data to user programs.

 I'd like some comment on the approach.

 01-mountstats.patch adds a new file called /proc/self/mountstats and a
 new file system method called show_stats.  this just replicates
 /proc/mounts and the show_options hook.

 02-nfs-iostat.patch teachs the NFS client to use the new show_stats
 hook as a demonstration.

 Note that this approach addresses previously voiced concerns about
 exporting per-superblock stats to user space.

 1. Processes can't see stats for file systems mounted outside their
    namespace.

 2. Reading the stats file is serialized with mount and unmount
    operations.

 3. The approach doesn't use /sys or kobjects.

 4. There are no lifetime issues tied to file systems loaded as a
    module.

