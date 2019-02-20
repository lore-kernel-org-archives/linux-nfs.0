Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3536C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 01:44:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 745052147A
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 01:44:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726235AbfBTBor (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 20:44:47 -0500
Received: from fieldses.org ([173.255.197.46]:47812 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725616AbfBTBor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 20:44:47 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 4AC131C9D; Tue, 19 Feb 2019 20:44:47 -0500 (EST)
Date:   Tue, 19 Feb 2019 20:44:47 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 06/10] NFSD add COPY_NOTIFY operation
Message-ID: <20190220014447.GE19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-7-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-7-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:44PM -0500, Olga Kornievskaia wrote:
> +	/**
> +	 * For now, only return one server address in cpn_src, the
> +	 * address used by the client to connect to this server.
> +	 */

Could you check your code for any places where you use /** as the
beginning of a comment?  The usual style is just /*, and /** is reserved
for specially-formatted comments meant to be extracted into
automatically-generated API documentation, so I think the above might
confuse kernel-doc.  (See Documentation/doc-guide/kernel-doc.rst.)

--b.
