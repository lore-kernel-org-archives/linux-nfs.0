Return-Path: <SRS0=3zAd=VG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 386AFC606B0
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 05:41:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 17EEE216C4
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 05:41:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725948AbfGIFk6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jul 2019 01:40:58 -0400
Received: from smtprelay0142.hostedemail.com ([216.40.44.142]:56051 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727230AbfGIFkz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2019 01:40:55 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay07.hostedemail.com (Postfix) with ESMTP id 1F860181D341A;
        Tue,  9 Jul 2019 05:40:54 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: bag59_7c29b583d1004
X-Filterd-Recvd-Size: 2614
Received: from XPS-9350 (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
        (Authenticated sender: joe@perches.com)
        by omf15.hostedemail.com (Postfix) with ESMTPA;
        Tue,  9 Jul 2019 05:40:53 +0000 (UTC)
Message-ID: <9a5dedb0c9221743033f28974820e8dd724e388d.camel@perches.com>
Subject: Re: [PATCH 8/8] nfsd: Fix misuse of strlcpy
From:   Joe Perches <joe@perches.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date:   Mon, 08 Jul 2019 22:40:50 -0700
In-Reply-To: <20190709031404.GD14439@fieldses.org>
References: <cover.1562283944.git.joe@perches.com>
         <b51141d12de77eb22101e81f9eb2c9cc44104d7a.1562283944.git.joe@perches.com>
         <20190709031404.GD14439@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-07-08 at 23:14 -0400, J. Bruce Fields wrote:
> On Thu, Jul 04, 2019 at 04:57:48PM -0700, Joe Perches wrote:
> > Probable cut&paste typo - use the correct field size.
> 
> Huh, that's been there forever, I wonder why we haven't seen crashes?
> Oh, I see, name and authname both have the same size.
> 
> Anyway, makes sense, thanks.  Will apply for 5.3.
> 
> (Unless someone else is getting this; I didn't get copied on the rest of
> the series.)

It's generally hard to cc everyone on treewide fixes like this.

There's no good mechanism I know of.
vger mailing lists reject emails with too many addressees.

Do you have an opinion on adding the stracpy macro which
could avoid many of these defects?

---
 include/linux/string.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 4deb11f7976b..ef01bd6f19df 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -35,6 +35,22 @@ ssize_t strscpy(char *, const char *, size_t);
 /* Wraps calls to strscpy()/memset(), no arch specific code required */
 ssize_t strscpy_pad(char *dest, const char *src, size_t count);
 
+#define stracpy(to, from)					\
+({								\
+	size_t size = ARRAY_SIZE(to);				\
+	BUILD_BUG_ON(!__same_type(typeof(*to), char));		\
+								\
+	strscpy(to, from, size);				\
+})
+
+#define stracpy_pad(to, from)					\
+({								\
+	size_t size = ARRAY_SIZE(to);				\
+	BUILD_BUG_ON(!__same_type(typeof(*to), char));		\
+								\
+	strscpy_pad(to, from, size);				\
+})
+
 #ifndef __HAVE_ARCH_STRCAT
 extern char * strcat(char *, const char *);
 #endif



