Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60C20C10F00
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 15:34:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3CBC12087C
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 15:34:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726826AbfCFPeg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 10:34:36 -0500
Received: from fieldses.org ([173.255.197.46]:41766 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726317AbfCFPeg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 10:34:36 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 16BB8BD8; Wed,  6 Mar 2019 10:34:35 -0500 (EST)
Date:   Wed, 6 Mar 2019 10:34:35 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Stephen Smalley <sds@tycho.nsa.gov>
Cc:     Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>, selinux@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] security/selinux: fix SECURITY_LSM_NATIVE_LABELS on
 reused superblock
Message-ID: <20190306153435.GF2426@fieldses.org>
References: <20190305211758.GA27437@fieldses.org>
 <ea347670-ea52-3ab6-a786-aeebff40dd0e@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea347670-ea52-3ab6-a786-aeebff40dd0e@tycho.nsa.gov>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 09:34:43AM -0500, Stephen Smalley wrote:
> On 3/5/19 4:17 PM, J. Bruce Fields wrote:
> >From: "J. Bruce Fields" <bfields@redhat.com>
> >
> >In the case when we're reusing a superblock, selinux_sb_clone_mnt_opts()
> >fails to set set_kern_flags, with the result that
> >nfs_clone_sb_security() incorrectly clears NFS_CAP_SECURITY_LABEL.
> >
> >The result is that if you mount the same NFS filesystem twice, NFS
> >security labels are turned off, even if they would work fine if you
> >mounted the filesystem only once.
> >
> >("fixes" may be not exactly the right tag, it may be more like
> >"fixed-other-cases-but-missed-this-one".)
> >
> >Cc: Scott Mayhew <smayhew@redhat.com>
> >Cc: stable@vger.kernel.org
> >Fixes: 0b4d3452b8b4 "security/selinux: allow security_sb_clone_mnt_opts..."
> >Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Acked-by: Stephen Smalley <sds@tycho.nsa.gov>
> 
> Do you have some tests you are using for the selinux nfs support?

No.  I'll ask around.  Trond or Anna, do either of you do any selinux
testing?

> I have an open issue on the selinux-testsuite with an example script
> for running the regular selinux tests on a NFS mount but it can't
> fully succeed as noted there,
> https://github.com/SELinuxProject/selinux-testsuite/issues/32

So if I just clone
https://github.com/SELinuxProject/selinux-testsuite.git and filter out
those known failures, would that be a good starting point?

> I've also have another script to test context= mount handling for
> nfs since that should take precedence over native labels; it looks
>  like that might be broken again:

Thanks for the report, I'll take a look.  That's before or after
applying this patch?  Assuming the former, do you have an idea how
recent a regression it is?

--b.

> #!/bin/sh
> cat > /etc/exports <<EOF
> /home localhost(rw,no_root_squash,security_label)
> EOF
> exportfs -a
> systemctl start nfs-server
> mkdir -p /mnt/home
> mount -t nfs -o vers=4.0,context=system_u:object_r:etc_t:s0
> localhost:/home /mnt/home
> echo "Under NFSv4.0:"
> ls -Za /mnt/home
> touch /mnt/home/foo
> ls -Z /mnt/home/foo
> ls -Z /home/foo
> rm /mnt/home/foo
> umount /mnt/home
> mount -t nfs -o vers=4.2,context=system_u:object_r:etc_t:s0
> localhost:/home /mnt/home
> echo "Under NFSv4.2:"
> ls -Za /mnt/home
> touch /mnt/home/foo
> ls -Z /mnt/home/foo
> ls -Z /home/foo
> rm /home/foo
> umount /mnt/home
> rmdir /mnt/home
> rm /etc/exports
> exportfs -ua
> systemctl stop nfs-server
> 
> >---
> >  security/selinux/hooks.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> >
> >diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> >index f0e36c3492ba..5e9304567233 100644
> >--- a/security/selinux/hooks.c
> >+++ b/security/selinux/hooks.c
> >@@ -959,8 +959,11 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
> >  	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
> >  	/* if fs is reusing a sb, make sure that the contexts match */
> >-	if (newsbsec->flags & SE_SBINITIALIZED)
> >+	if (newsbsec->flags & SE_SBINITIALIZED) {
> >+		if ((kern_flags & SECURITY_LSM_NATIVE_LABELS) && !set_context)
> >+			*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
> >  		return selinux_cmp_sb_context(oldsb, newsb);
> >+	}
> >  	mutex_lock(&newsbsec->lock);
> >
