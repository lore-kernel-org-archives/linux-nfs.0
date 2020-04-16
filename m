Return-Path: <SRS0=UO7P=6A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93705C2BB55
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 14:34:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 774FB21927
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 14:34:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2410132AbgDPO2u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Apr 2020 10:28:50 -0400
Received: from fieldses.org ([173.255.197.46]:51266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2410120AbgDPO2r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Apr 2020 10:28:47 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 313741510; Thu, 16 Apr 2020 10:28:45 -0400 (EDT)
Date:   Thu, 16 Apr 2020 10:28:45 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: GSS unwrapping breaks the DRC
Message-ID: <20200416142845.GA28206@fieldses.org>
References: <DAED9EC8-7461-48FF-AD6C-C85FB968F8A6@oracle.com>
 <20200415192542.GA6466@fieldses.org>
 <0775FBE7-C2DD-4ED6-955D-22B944F302E0@oracle.com>
 <20200415215823.GB6466@fieldses.org>
 <39815C35-EAD8-4B2E-B48F-88F3D5B10C57@oracle.com>
 <20200416000009.GA13083@fieldses.org>
 <B6923717-3396-4DC2-AD63-1C5797B2471C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B6923717-3396-4DC2-AD63-1C5797B2471C@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 16, 2020 at 10:07:27AM -0400, Chuck Lever wrote:
> The bigger picture is updating the server to use xdr_stream throughout
> its XDR stack. That's the main reason I worked on the client-side GSS
> wrap and unwrap functions last year.
> 
> Using xdr_stream would move the server and client sides closer together
> in style and implementation, then hopefully we could share more code.

I'm all for that, though I'm not sure it's the same problem.

The krb5i/krb5p implementation isn't based on xdr_stream on either the
client or the server.

But yes maybe it would force thinking about what the different xdr_buf
fields mean in a way that would clarify things.  I don't know.

--b.
