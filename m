Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C0F8ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:07:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0B9D20848
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 16:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0B9D20848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727699AbeJZAlF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:41:05 -0400
Received: from fieldses.org ([173.255.197.46]:47322 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727319AbeJZAlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 20:41:04 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 72EFE1E3D; Thu, 25 Oct 2018 12:07:39 -0400 (EDT)
Date:   Thu, 25 Oct 2018 12:07:39 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 00/13] server-side support for "inter" SSC copy
Message-ID: <20181025160739.GC5539@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:28:52AM -0400, Olga Kornievskaia wrote:
> This patch series adds support for NFSv4.2 copy offload feature
> allowing copy between two different NFS servers.

Apologies, it may take me another week or so to get to this....

This is the part that sounds trickiest!:

> On the destination server, upon receiving a COPY request, the server
> establishes the necessary clientid/session with the source server.
> It calls into the NFS client code to establish the necessary
> open stateid, filehandle, file description (without doing an NFS open).
> Then the server calls into the copy_file_range() to preform the copy
> where the source file will issue NFS READs and then do local file
> system writes (this depends on the VFS ability to do cross device
> copy_file_range().

--b.
