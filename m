Return-Path: <SRS0=aTES=WC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC09EC433FF
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Aug 2019 12:19:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9440C20B1F
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Aug 2019 12:19:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726783AbfHFMTf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Aug 2019 08:19:35 -0400
Received: from mga07.intel.com ([134.134.136.100]:22593 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726877AbfHFMTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Aug 2019 08:19:34 -0400
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 05:19:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="176618250"
Received: from smile.fi.intel.com (HELO smile) ([10.237.68.145])
  by orsmga003.jf.intel.com with ESMTP; 06 Aug 2019 05:19:33 -0700
Received: from andy by smile with local (Exim 4.92)
        (envelope-from <andriy.shevchenko@intel.com>)
        id 1huyR9-0007i3-Lh; Tue, 06 Aug 2019 15:19:31 +0300
Date:   Tue, 6 Aug 2019 15:19:31 +0300
From:   Andy Shevchenko <andriy.shevchenko@intel.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/16] nfsd: escape high characters in binary data
Message-ID: <20190806121931.GA29578@smile.fi.intel.com>
References: <1561042275-12723-1-git-send-email-bfields@redhat.com>
 <1561042275-12723-9-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561042275-12723-9-git-send-email-bfields@redhat.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jun 20, 2019 at 10:51:07AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> I'm exposing some information about NFS clients in pseudofiles.  I
> expect to eventually have simple tools to help read those pseudofiles.
> 
> But it's also helpful if the raw files are human-readable to the extent
> possible.  It aids debugging and makes them usable on systems that don't
> have the latest nfs-utils.
> 
> A minor challenge there is opaque client-generated protocol objects like
> state owners and client identifiers.  Some clients generate those to
> include handy information in plain ascii.  But they may also include
> arbitrary byte sequences.
> 
> I think the simplest approach is to limit to isprint(c) && isascii(c)
> and escape everything else.
> 
> That means you can just cat the file and get something that looks OK.
> Also, I'm trying to keep these files legal YAML, which requires them to
> UTF-8, and this is a simple way to guarantee that.

Two questions:
- why can't be original function extended to cover this case
  (using additional flags, maybe)?
- where are the test cases?

-- 
With Best Regards,
Andy Shevchenko


