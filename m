Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E77C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 17:03:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3CB3E20840
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 17:03:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728531AbfCARDl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 12:03:41 -0500
Received: from fieldses.org ([173.255.197.46]:35018 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728507AbfCARDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Mar 2019 12:03:41 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 3B56049A; Fri,  1 Mar 2019 12:03:41 -0500 (EST)
Date:   Fri, 1 Mar 2019 12:03:41 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] NFSD: Add support for the v4.2 READ_PLUS operation
Message-ID: <20190301170341.GC17671@fieldses.org>
References: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 04:58:48PM -0500, Anna Schumaker wrote:
> These patches add server support for the READ_PLUS operation.  This
> operation is meant to improve file reading performance when working with
> sparse files, but there are some issues around the use of vfs_llseek() to
> identify hole and data segments when encoding the reply.  I've done a
> bunch of testing on virtual machines,

Maybe the VM<->VM case is important too, but it'd be a little easier to
understand a case with real hardware, I think.  What kind of disk are
you using, our of curiosity?

Also, what are the file sizes, and the rsize?  (Apologies if I
overlooked that.)

> and I found that READ_PLUS performs best if:

It's interesting to think about why these are:

>   1) The file being read is not yet in the server's page cache.

I don't understand this one.

>   2) The read request begins with a hole segment. And

If I understand your current implementation, it's basically:

	- seek with SEEK_DATA.
	- if that finds a hole, read the rest of the requested range and
	  return two segments (a hole plus ordinary read results)
	- otherwise just return ordinary read data for the whole range.

So, right, in the case the read range starts with data, the seek was
just a waste of time, makes sense.

>   3) The server only performs one llseek() call during encoding

OK, so for that we'd need to compare to a different implementation,
which is what you did elsewhere:

> I also have performance numbers for if we encode every hole and data
> segment but I figured this email was long enough already. I'm happy to
> share it if requested!

Got it.  (And, sure, that might be interesting.)

--b.
