Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8949CC43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 16:23:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 50C4620825
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 16:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50C4620825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727828AbeKJCEZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 21:04:25 -0500
Received: from mx1.redhat.com ([209.132.183.28]:9743 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728026AbeKJCEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Nov 2018 21:04:25 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DEE97307D91C;
        Fri,  9 Nov 2018 16:23:09 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-117-179.phx2.redhat.com [10.3.117.179])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 871C65D9CA;
        Fri,  9 Nov 2018 16:23:09 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id C56C018019C; Fri,  9 Nov 2018 11:23:08 -0500 (EST)
Date:   Fri, 9 Nov 2018 11:23:08 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 13/13] NFSD add nfs4 inter ssc to nfsd4_copy
Message-ID: <20181109162308.GB2293@parsley.fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-14-olga.kornievskaia@gmail.com>
 <20181107214850.GC19588@fieldses.org>
 <CAN-5tyFQHCgvtyp1Or3-y4qeKvAYVJCj5NtLiDrDN4vwNY8f_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyFQHCgvtyp1Or3-y4qeKvAYVJCj5NtLiDrDN4vwNY8f_w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 09 Nov 2018 16:23:09 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 08, 2018 at 02:16:04PM -0500, Olga Kornievskaia wrote:
> On Wed, Nov 7, 2018 at 4:49 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:29:05AM -0400, Olga Kornievskaia wrote:
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > Given a universal address, mount the source server from the destination
> > > server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
> > > obtain the NFS struct file suitable for nfsd_copy_range.
> > >
> > > Ability to do "inter" server-to-server depends on the an nfsd kernel
> > > parameter "inter_copy_offload_enabled".
> > >
> > > Signed-off-by: Andy Adamson <andros@netapp.com>
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  fs/nfsd/nfs4proc.c   | 298 ++++++++++++++++++++++++++++++++++++++++++++++++---
> > >  fs/nfsd/nfssvc.c     |   6 ++
> > >  fs/nfsd/xdr4.h       |   5 +
> > >  include/linux/nfs4.h |   1 +
> > >  4 files changed, 293 insertions(+), 17 deletions(-)
> > >
> > > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > > index 59e9d0c..6dcd80c 100644
> > > --- a/fs/nfsd/nfs4proc.c
> > > +++ b/fs/nfsd/nfs4proc.c
> > > @@ -1153,6 +1153,229 @@ void nfsd4_shutdown_copy(struct nfs4_client *clp)
> > >       while ((copy = nfsd4_get_copy(clp)) != NULL)
> > >               nfsd4_stop_copy(copy);
> > >  }
> > > +#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> > > +
> > > +extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
> > > +                                struct nfs_fh *src_fh,
> > > +                                nfs4_stateid *stateid);
> > > +extern void nfs42_ssc_close(struct file *filep);
> > > +
> > > +extern void nfs_sb_deactive(struct super_block *sb);
> > > +
> > > +#define NFSD42_INTERSSC_MOUNTOPS "minorversion=2,vers=4,addr=%s,clientaddr=%s"
> >
> > The nfs man page says "clientaddr=" has no effect on 4.2 mounts.
> 
> I only have nfs man page from RHEL7.5 and I don't see that.

From nfs-utils/utils/mount/nfs.man:

	NFS protocol versions 4.1 and 4.2 use the client-established TCP
	connection for callback requests, so do not require the server
	to connect to the client.  This option is therefore only affect
	NFS version 4.0 mounts.

(Maybe I should send a patch for that "is therefore" typo.)

> > Also, what's the "addr=" option for, isn't the server address already
> > given in the mount string?  (Honest question, I may be wrong here.)
> 
> I believe going thru the kernel vfs_kern_mount() we need to specify
> "addr=" otherwise it doesn't know which server to mount.

Yeah, now that I think of it I guess the kernel hasn't traditionally
done DNS resolution so of course there'd have to be something like this.
OK.

> > > +
> > > +/**
> > > + * Support one copy source server for now.
> > > + */
> > > +static struct vfsmount *
> > > +nfsd4_interssc_connect(struct nl4_server *nss, struct svc_rqst *rqstp)
> > > +{
> > > +     struct file_system_type *type;
> > > +     struct vfsmount *ss_mnt;
> > > +     struct nfs42_netaddr *naddr;
> > > +     struct sockaddr_storage tmp_addr;
> > > +     size_t tmp_addrlen, match_netid_len = 3;
> > > +     char *startsep = "", *endsep = "", *match_netid = "tcp";
> > > +     char *ipaddr, *ipaddr2, *raw_data;
> > > +     int len, raw_len, status = -EINVAL;
> > > +
> > > +     /* Currently support only NL4_NETADDR source server */
> > > +     if (nss->nl4_type != NL4_NETADDR) {
> > > +             WARN(nss->nl4_type != NL4_NETADDR,
> > > +                     "nfsd4_copy src server not NL4_NETADDR\n");
> >
> > Won't nfsd4_decode_nl4_server actually let through NL4_NAME and NL4_URL?
> 
> Yes. I think the logic would be not to limit the xdr functionality
> from not parsing it as if the support in the main code the xdr code
> doesn't change.

I think it would be simplest just to return the right error from
nfsd4_decode_nl4_server() in the NL4_NAME/NL4_URL cases.

> > That would make this WARN() triggerable by a client--that's bad.
> 
> Why? Would you rather it silently failed?

Returning an error would be fine.

But it should never be possible for an ordinary user or somebody on the
network to trigger a WARN() or a BUG().  Those should be reserved for
things that we assume never happen (so they indicate that our
assumptions are wrong, hence we have a possible kernel bug).

> Thank you for the reviews. I'm working on the next version. But in
> addition to this, I need the VFS piece with this patch series now
> because server piece needs the generic cross filesystem
> copy_file_range() support via do_splice because the server reads out
> of NFS and writes into the local file system.

OK.  In addition to mailing the patches it might also be useful if you
could point me to a git branch somewhere just to make sure I've got all
the right prerequisites.

--b.
