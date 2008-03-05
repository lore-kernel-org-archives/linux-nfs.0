From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2-v2] NFS: use new LSM interfaces to explicitly set
	mount options
Date: Wed, 05 Mar 2008 14:34:24 -0500
Message-ID: <1204745664.5035.12.camel@heimdal.trondhjem.org>
References: <1204744818.3216.254.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	casey@schaufler-ca.com, chuck.lever@oracle.com, hch@infradead.org,
	akpm@linux-foundation.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1204744818.3216.254.camel@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-05 at 14:20 -0500, Eric Paris wrote:
> NFS and SELinux worked together previously because SELinux had NFS
> specific knowledge built in.  This design was approved by both groups
> back in 2004 but the recent NFS changes to use nfs_parsed_mount_data and
> the usage of nfs_clone_mount_data showed this to be a poor fragile
> solution.  This patch fixes the NFS functionality regression by making
> use of the new LSM interfaces to allow an FS to explicitly set its own
> mount options.
> 
> The explicit setting of mount options is done in the nfs get_sb
> functions which are called before the generic vfs hooks try to set mount
> options for filesystems which use text mount data.
> 
> This does not currently support NFSv4 as that functionality did not
> exist in previous kernels and thus there is no regression.  I will be
> adding the needed code, which I believe to be the exact same as the v3
> code, in nfs4_get_sb for 2.6.26.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>


