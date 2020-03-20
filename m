Return-Path: <SRS0=0eYR=5F=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21060C4332D
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Mar 2020 19:45:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE74220739
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Mar 2020 19:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="bArwFKJz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726783AbgCTTo7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Mar 2020 15:44:59 -0400
Received: from smtp-fw-6001.amazon.com ([52.95.48.154]:50115 "EHLO
        smtp-fw-6001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726738AbgCTTo7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2020 15:44:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1584733498; x=1616269498;
  h=date:from:to:cc:message-id:references:mime-version:
   in-reply-to:subject;
  bh=hCk0+f7C2b5TFbmIog853xS9XgpzP9SyFKxk5zx0ez0=;
  b=bArwFKJzip3x/2hPSZ4qYyGn9+//du5ba6AYLdFfsEYNfH2XN1gA7MKS
   Lm+M9PVA6t3U0Sg9hujm7pYObrFurbZqiBzrchGmA4YqnkH/NiknV8YGR
   yPU/WHvJ9n8WWU4w6FO3vvaOOC/n/oPuVClo5HWk3SDKOQKazg9I0yvvW
   U=;
IronPort-SDR: VIJALoh4PtUpgqSG4y2WNUICarHwhronqPBSX3BzT/X/23GXOsf5tcdmZQcD6TnsRcnfRPeSq1
 J7oBoNtz4qAA==
X-IronPort-AV: E=Sophos;i="5.72,285,1580774400"; 
   d="scan'208";a="23431618"
Subject: Re: [PATCH 11/14] nfsd: add user xattr RPC XDR encoding/decoding logic
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-1e-c7c08562.us-east-1.amazon.com) ([10.43.8.6])
  by smtp-border-fw-out-6001.iad6.amazon.com with ESMTP; 20 Mar 2020 19:44:46 +0000
Received: from EX13MTAUWC001.ant.amazon.com (iad55-ws-svc-p15-lb9-vlan2.iad.amazon.com [10.40.159.162])
        by email-inbound-relay-1e-c7c08562.us-east-1.amazon.com (Postfix) with ESMTPS id E1A112415A3;
        Fri, 20 Mar 2020 19:44:45 +0000 (UTC)
Received: from EX13D02UWC004.ant.amazon.com (10.43.162.236) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Fri, 20 Mar 2020 19:44:45 +0000
Received: from EX13MTAUWC001.ant.amazon.com (10.43.162.135) by
 EX13D02UWC004.ant.amazon.com (10.43.162.236) with Microsoft SMTP Server (TLS)
 id 15.0.1497.2; Fri, 20 Mar 2020 19:44:44 +0000
Received: from dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com
 (172.23.141.97) by mail-relay.amazon.com (10.43.162.232) with Microsoft SMTP
 Server id 15.0.1367.3 via Frontend Transport; Fri, 20 Mar 2020 19:44:44 +0000
Received: by dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com (Postfix, from userid 6262777)
        id B3D30D49F5; Fri, 20 Mar 2020 19:44:44 +0000 (UTC)
Date:   Fri, 20 Mar 2020 19:44:44 +0000
From:   Frank van der Linden <fllinden@amazon.com>
To:     Chuck Lever <chuck.lever@oracle.com>
CC:     Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <20200320194444.GA7991@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
References: <20200311195954.27117-1-fllinden@amazon.com>
 <20200311195954.27117-12-fllinden@amazon.com>
 <6955728A-CFCC-40FC-9E02-671255EDD45F@oracle.com>
 <20200320164737.GA19415@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
 <65ACAC76-DBBE-42D3-ACED-AB2290D0FC31@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <65ACAC76-DBBE-42D3-ACED-AB2290D0FC31@oracle.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 20, 2020 at 01:34:53PM -0400, Chuck Lever wrote:
> 
> For my peace of mind, "from_stream" implies there _is_ an xdr_stream
> in use, even though the function does not have a struct xdr_stream
> parameter. Perhaps a different naming scheme would be wise.

Sure. I'll change it to "from_vector", which matches the name of the
"svcxdr_construct_vector" function. Not 100% correct, since it's really
a vector + page array, but it seems better.

- Frank
