Return-Path: <SRS0=W+du=V6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCA02C433FF
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Aug 2019 09:12:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9F003205F4
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Aug 2019 09:12:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564737178;
	bh=JrP72r6LstQeI6Dz9wti4WjfN6tNHcW2sHlVYyQng/I=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=AOcMG4K7aGbnWraM17x016HiBx7P1dDMEqI0cLtH4bNW2QkLH7LG74Hh5s6uYmL4o
	 wHrJiP0I77Pq/mvvQ1Ga8ZV1LQCi1S9QX9QrjJRwqZUDM5ig1SdKT1gcaYr/+2iBKP
	 qroF9QXV9fPOmn7mMCiPluF+R7vUsSi9IOOo1n2M=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732804AbfHBJMv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Aug 2019 05:12:51 -0400
Received: from mx2.suse.de ([195.135.220.15]:54294 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727127AbfHBJMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Aug 2019 05:12:50 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 4990DAFE2;
        Fri,  2 Aug 2019 09:12:47 +0000 (UTC)
Date:   Fri, 2 Aug 2019 11:12:44 +0200
From:   Michal Hocko <mhocko@kernel.org>
To:     john.hubbard@gmail.com
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Chinner <david@fromorbit.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
        Jason Gunthorpe <jgg@ziepe.ca>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        amd-gfx@lists.freedesktop.org, ceph-devel@vger.kernel.org,
        devel@driverdev.osuosl.org, devel@lists.orangefs.org,
        dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
        kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-media@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
        netdev@vger.kernel.org, rds-devel@oss.oracle.com,
        sparclinux@vger.kernel.org, x86@kernel.org,
        xen-devel@lists.xenproject.org, John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190802091244.GD6461@dhcp22.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
[...]
> 2) Convert all of the call sites for get_user_pages*(), to
> invoke put_user_page*(), instead of put_page(). This involves dozens of
> call sites, and will take some time.

How do we make sure this is the case and it will remain the case in the
future? There must be some automagic to enforce/check that. It is simply
not manageable to do it every now and then because then 3) will simply
be never safe.

Have you considered coccinele or some other scripted way to do the
transition? I have no idea how to deal with future changes that would
break the balance though.
-- 
Michal Hocko
SUSE Labs
