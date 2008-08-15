From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Fri, 15 Aug 2008 17:04:12 -0400
Message-ID: <1218834252.7037.31.camel@localhost>
References: <20080701182250.GB21807@fieldses.org>
	 <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org>
	 <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com>
	 <20080717144852.GA11759@fieldses.org>
	 <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com>
	 <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com>
	 <20080730175308.GH12364@fieldses.org>
	 <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com>
	 <76bd70e30807301501p5c0ba3c6i38fee02a1e606e31@mail.gmail.com>
	 <76bd70e30808151334i19822280j67a08b92b17582ba@mail.gmail.com>
	 <1218833230.7037.29.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PqUl/OsTLSOX81su4yeI"
Cc: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2601 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758771AbYHOVEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Aug 2008 17:04:37 -0400
In-Reply-To: <1218833230.7037.29.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-PqUl/OsTLSOX81su4yeI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2008-08-15 at 16:47 -0400, Trond Myklebust wrote:
> On Fri, 2008-08-15 at 16:34 -0400, Chuck Lever wrote:
> > Trond, NFS_MOUNT_FLAGMASK is used in nfs_init_server() and
> > nfs4_init_server() for both legacy binary and text-based mounts.  This
> > needs to be moved to a legacy-only path if we want to use the
> > high-order 16 bits in the 'flags' field for text-based mounts.
> 
> We definitely want to do this. The point of introducing text-based
> mounts was to allow us to add functionality without having to worry
> about legacy binary mount formats. The mask should be there in order to
> ensure that binary formats don't start enabling features that they
> cannot support. There is no justification for applying it to the text
> mount path.

I've attached the patch...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--=-PqUl/OsTLSOX81su4yeI
Content-Disposition: attachment; filename*0=linux-2.6.27-005-dont_apply_nfs_mount_flagmask_to_text_mounts; filename*1=.dif
Content-Type: message/rfc822; name=linux-2.6.27-005-dont_apply_nfs_mount_flagmask_to_text_mounts.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 15 Aug 2008 16:59:14 -0400
NFS: Don't apply NFS_MOUNT_FLAGMASK to text-based mounts
Subject: No Subject
Message-Id: <1218834252.7037.32.camel@localhost>
Mime-Version: 1.0

The point of introducing text-based mounts was to allow us to add
functionality without having to worry about legacy binary mount formats.
The mask should be there in order to ensure that binary formats don't start
enabling features that they cannot support. There is no justification for
applying it to the text mount path.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |    4 ++--
 fs/nfs/super.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2accb67..7547600 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -675,7 +675,7 @@ static int nfs_init_server(struct nfs_server *server,
 	server->nfs_client = clp;
 
 	/* Initialise the client representation from the mount data */
-	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+	server->flags = data->flags;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
@@ -1072,7 +1072,7 @@ static int nfs4_init_server(struct nfs_server *server,
 		goto error;
 
 	/* Initialise the client representation from the mount data */
-	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+	server->flags = data->flags;
 	server->caps |= NFS_CAP_ATOMIC_OPEN;
 
 	if (data->rsize)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f67d44c..5725af9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1544,7 +1544,7 @@ static int nfs_validate_mount_data(void *options,
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
 		 */
-		args->flags		= data->flags;
+		args->flags		= data->flags & NFS_MOUNT_FLAGMASK;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
 		args->timeo		= data->timeo;

--=-PqUl/OsTLSOX81su4yeI--
