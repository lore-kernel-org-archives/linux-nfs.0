Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45510 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab0H3Aad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 20:30:33 -0400
Date: Mon, 30 Aug 2010 10:30:25 +1000
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Message-ID: <20100830103025.70d09ec8@notabene>
In-Reply-To: <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
References: <20100826120635.4c3157bc@notabene>
	<659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 26 Aug 2010 10:51:23 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:
> 
> > 
> > Currently if the server doesn't support TCP (and so doesn't support NFSv4)
> > we don't fall-back to NFSv3.  This is because 'ECONNREFUSED' isn't deemed to
> > be a suitable error for falling back.  Rather we wait for about 2 minutes,
> > then give up.
> > 
> > There is some justification for this:  ECONNREFUSED could just mean that the
> > server isn't quite ready yet.
> > 
> > I'm not really sure what the best thing to do here would be.  We don't really
> > want to try v3 and have fail only because it was just enough later that nfsd
> > is now responding.
> > 
> > Maybe the ideal would be to do a portmap probe and only fall back to v3 if
> > portmap confirm that v3 is supported and v4 isn't.
> > 
> > For now I just present this patch which allows fallback to v3 providing tcp
> > wasn't explicitly requested.
> > 
> > Thoughts?
> 
> What are the risks of checking portmap in this case?  That seems like it would give a better chance of a desirable outcome.

True, I was just too lazy at the time.

How about this:
  If nfs_try_mount_v4 return ECONNREFUSED we do a portmap lookup and see
  which versions and protocols are supported.
  If nothing is registered, or if any version support TCP, then we take the
  current approach or waiting and trying again on the assumption that the
  server is still starting up and wasn't quite ready yet when we got the
  ECONNREFUSED.
  However if UDP support is available but TCP isn't, and if the mount options
  don't specify a protocol, then fall back to v2v3.

So here is my second draft.  The 'verbose' results will be a bit confusing
but I think the functionality is close to what I want - it just does the pmap
lookups twice.

NeilBrown


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..913b563 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -93,6 +93,7 @@ struct nfsmount_info {
 	char			**extra_opts;	/* string for /etc/mtab */
 
 	unsigned long		version;	/* NFS version */
+	unsigned long		proto;		/* protocol chosen */
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
@@ -625,6 +626,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
 	if (!nfs_rewrite_pmap_mount_options(options))
 		goto out_fail;
 
+	/* record which protocol was chosen */
+	nfs_nfs_protocol(options, &mi->proto);
+
 	result = nfs_sys_mount(mi, options);
 
 out_fail:
@@ -762,6 +766,29 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 			errno = 0;
 			result = nfs_try_mount_v4(mi);
 			if (errno != EPROTONOSUPPORT) {
+				/* If server only handles UDP, then v4 will have
+				 * received ECONNREFUSED for TCP, so fall through
+				 * to v3v2 which can try udp, but only if tcp
+				 * wasn't explicitly requested
+				 */
+				if (errno == ECONNREFUSED) {
+					unsigned long proto;
+					if (nfs_nfs_protocol(mi->options, &proto) == 1 &&
+					    proto == 0) {
+						/* OK to try different protocols. Lets see
+						 * what portmap thinks.
+						 */
+						int oldfake = mi->fake;
+						int res;
+						mi->fake = 1;
+						res = nfs_try_mount_v3v2(mi);
+						mi->fake = oldfake;
+						if (!res || mi->proto != IPPROTO_UDP)
+							/* time out and try again */
+							break;
+					} else
+						break;
+				} else
 				/* 
 				 * To deal with legacy Linux servers that don't
 				 * automatically export a pseudo root, retry


