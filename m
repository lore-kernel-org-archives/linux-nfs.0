Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:38742 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab1EPTSR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 15:18:17 -0400
Date: Mon, 16 May 2011 15:18:11 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Removed compilation warnings from mountd/cache.c
Message-ID: <20110516191811.GA1048@merit.edu>
References: <1305561014-25688-1-git-send-email-steved@redhat.com>
 <20110516172927.GA1348@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110516172927.GA1348@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  On Mon, May 16, 2011 at 11:50:14AM -0400, Steve Dickson wrote:
  > Commit 5604b35a6 introduced a number of missing initializer
  > warnings that were missed. This patch removes those warnings.
  > 
  > Signed-off-by: Steve Dickson <steved@redhat.com>
  > ---
  >  utils/mountd/cache.c |    6 ++++--
  >  1 files changed, 4 insertions(+), 2 deletions(-)
  > 
  > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
  > index df6b38f..86a2790 100644
  > --- a/utils/mountd/cache.c
  > +++ b/utils/mountd/cache.c
  > @@ -825,7 +825,6 @@ struct {
  >  	char *cache_name;
  >  	void (*cache_handle)(FILE *f);
  >  	FILE *f;
  > -	char vbuf[RPC_CHAN_BUF_SIZE];
  >  } cachelist[] = {
  >  	{ "auth.unix.ip", auth_unix_ip, NULL},
  >  	{ "auth.unix.gid", auth_unix_gid, NULL},
  > @@ -833,6 +832,9 @@ struct {
  >  	{ "nfsd.fh", nfsd_fh, NULL},
  >  	{ NULL, NULL, NULL }
  >  };
  > +struct vbs {
  > +	char vbuf[RPC_CHAN_BUF_SIZE];
  > +} vbufs [(sizeof(cachelist)/sizeof(cachelist[0])) - 1];
  
  Weird--why does that make a difference?  It's statically initialized
  memory either way, isn't it?

The problem is the vbuf item was added to the struct but no initializer was
given for it.  It could also have been fixed by supplying the missing
initializer:

	{ "auth.unix.ip", auth_unix_ip, NULL, ""}, ...
