Return-Path: <SRS0=U+gK=XH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A8CC4CEC7
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Sep 2019 20:23:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7EDB020830
	for <linux-nfs@archiver.kernel.org>; Thu, 12 Sep 2019 20:23:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726032AbfILUXx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 12 Sep 2019 16:23:53 -0400
Received: from fieldses.org ([173.255.197.46]:35180 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725995AbfILUXw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Sep 2019 16:23:52 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 80E142010; Thu, 12 Sep 2019 16:23:52 -0400 (EDT)
Date:   Thu, 12 Sep 2019 16:23:52 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 05/19] NFS: inter ssc open
Message-ID: <20190912202352.GB5054@fieldses.org>
References: <20190906194631.3216-1-olga.kornievskaia@gmail.com>
 <20190906194631.3216-6-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906194631.3216-6-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Sep 06, 2019 at 03:46:17PM -0400, Olga Kornievskaia wrote:
> +static int read_name_gen = 1;
> +#define SSC_READ_NAME_BODY "ssc_read_%d"
> +
...
> +	res = ERR_PTR(-ENOMEM);
> +	len = strlen(SSC_READ_NAME_BODY) + 16;
> +	read_name = kzalloc(len, GFP_NOFS);
> +	if (read_name == NULL)
> +		goto out;
> +	snprintf(read_name, len, SSC_READ_NAME_BODY, read_name_gen++);
...
> +	filep = alloc_file_pseudo(r_ino, ss_mnt, read_name, FMODE_READ,
> +				     r_ino->i_fop);

So, I"m curious: does this "name" ever get used anywhere?  Can you see
it from userspace somehow, for example?  Does it have some debugging
value?  Or could it just be the empty string?

--b.
