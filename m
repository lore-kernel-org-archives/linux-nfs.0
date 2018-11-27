Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC4CC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 20:58:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CED8F21104
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 20:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED8F21104
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726342AbeK1H56 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 02:57:58 -0500
Received: from fieldses.org ([173.255.197.46]:43432 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726286AbeK1H56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 02:57:58 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 8D4E01EF6; Tue, 27 Nov 2018 15:58:49 -0500 (EST)
Date:   Tue, 27 Nov 2018 15:58:49 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFSd: NULL-dereference when writing to v4_end_grace when server
 is not yet started
Message-ID: <20181127205849.GB12810@fieldses.org>
References: <CAE5jQCcNCcLX_UvhHFe7BmxE010ULbchd1WN7pDbE2enK-pDZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE5jQCcNCcLX_UvhHFe7BmxE010ULbchd1WN7pDbE2enK-pDZg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Nov 25, 2018 at 09:17:10AM +0300, Anatoly Trosinenko wrote:
> When manually exploring the kernel NFSd feature, I have stumbled upon
> a NULL-dereference when writing to v4_end_grace when server is not yet
> started.

Thanks for the report!

I think this is what we want--it's what a lot of the other nfsctl
methods do.

--b.

commit ad5fdf47b4e3
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Nov 27 15:54:17 2018 -0500

    nfsd4: fix crash on writing v4_end_grace before nfsd startup
    
    Anatoly Trosinenko reports that this:
    
    1) Checkout fresh master Linux branch (tested with commit e195ca6cb)
    2) Copy x84_64-config-4.14 to .config, then enable NFS server v4 and build
    3) From `kvm-xfstests shell`:
    
    results in NULL dereference in locks_end_grace.
    
    Check that nfsd has been started before trying to end the grace period.
    
    Reported-by: Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6384c9b94898..38b223c1378e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1126,7 +1126,13 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
 		case 'Y':
 		case 'y':
 		case '1':
+			mutex_lock(&nfsd_mutex);
+			if (nn->nfsd_serv) {
+				mutex_unlock(&nfsd_mutex);
+				return -EBUSY;
+			}
 			nfsd4_end_grace(nn);
+			mutex_unlock(&nfsd_mutex);
 			break;
 		default:
 			return -EINVAL;
