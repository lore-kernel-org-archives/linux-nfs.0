From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/5] gfs2: stop giving out non-cluster-coherent leases
Date: Mon, 11 Jun 2007 13:07:19 -0400
Message-ID: <20070611170719.GC9135@fieldses.org>
References: <OF0E226FEB.28B3A3C4-ON882572F5.005A6853-882572F5.005B16B6@us.ibm.com> <1181554698.25918.300.camel@quoit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Eshel <eshel@almaden.ibm.com>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1181554698.25918.300.camel@quoit>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, Jun 11, 2007 at 10:38:18AM +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Sat, 2007-06-09 at 09:35 -0700, Marc Eshel wrote:
> > This is the return code that setlease() currently returns when the lease 
> > can not be obtained. Although ENOTSUPP would be more accurately describing 
> > the error it will be a new return code from setlease() that is currently 
> > not expected by callers to setlease(), but either return code should work.
> > Marc. 
> > 
> I prefer EOPNOTSUPP as it more accurately describes whats going on here.
> EAGAIN seems to me to imply that its something thats blocking
> temporarily and that trying again at a later time might result in
> success,

OK.  Well, if we hold to the theory that nobody sane was getting leases
in these situations before anyway, then I guess we can assume we're free
to define the error returns that make sense to us unconstrained by
application behavior.

So for now I've made the returns -EOPNOTSUPP in both the nfs and gfs2
cases; updated version available from:

	git://linux-nfs.org/~bfields/linux.git server-cluster-lease-api

--b.

diff --git a/fs/gfs2/ops_file.c b/fs/gfs2/ops_file.c
index 654000b..e34d9bd 100644
--- a/fs/gfs2/ops_file.c
+++ b/fs/gfs2/ops_file.c
@@ -500,7 +500,7 @@ static int gfs2_fsync(struct file *file, struct dentry *dentry, int datasync)
 static int gfs2_setlease(struct file *file, long arg, struct file_lock **fl)
 {
 	struct gfs2_sbd *sdp = GFS2_SB(file->f_mapping->host);
-	int ret = EAGAIN;
+	int ret = -EOPNOTSUPP;
 
 	if (sdp->sd_args.ar_localflocks) {
 		return setlease(file, arg, fl);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 467671b..97c1a3d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -560,5 +560,5 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 
 static int nfs_setlease(struct file *file, long arg, struct file_lock **fl)
 {
-	return -EINVAL;
+	return -EOPNOTSUPP;
 }
