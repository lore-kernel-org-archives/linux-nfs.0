Return-Path: <SRS0=3Jq2=PS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFFDDC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:29:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A872F20879
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:29:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728993AbfAJU3O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Jan 2019 15:29:14 -0500
Received: from fieldses.org ([173.255.197.46]:48874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727665AbfAJU3O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Jan 2019 15:29:14 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id A6DC363E; Thu, 10 Jan 2019 15:29:13 -0500 (EST)
Date:   Thu, 10 Jan 2019 15:29:13 -0500
To:     Rik Theys <Rik.Theys@esat.kuleuven.be>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: status of NFS4 acls and umask
Message-ID: <20190110202913.GD15492@fieldses.org>
References: <0dd5344e-231f-1670-ffe1-5974b57dbaf3@esat.kuleuven.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0dd5344e-231f-1670-ffe1-5974b57dbaf3@esat.kuleuven.be>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 11, 2018 at 02:11:59PM +0100, Rik Theys wrote:
> In https://www.spinics.net/lists/linux-nfs/msg27799.html from 2011, Jeff
> Layton describes how/why an NFSv4 ACL does not override the umask like a
> posix ACL does. It mentions that it did not work back then and that
> something might be done about that.
> 
> What is the status now? When I look at the CentOS 7.6 client/server it
> seems this is still not implemented. Is this fixed in newer upstream
> versions? If not, are there any plans on finding a solution?

I'ts fixed if your NFSv4.2 client and server implement
https://tools.ietf.org/html/rfc8275, which upstream linux client and
server now do.  For RHEL I believe that change went into 7.4.  If that's
not working for you, you may need to check that the protocol version is
4.2.

--b.
