Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40452 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0GGRBH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 13:01:07 -0400
Date: Wed, 7 Jul 2010 13:00:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4
 flags
Message-ID: <20100707170058.GD28815@fieldses.org>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
 <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 07, 2010 at 10:31:22AM -0400, David P. Quigley wrote:
> This patch adds a new recommended attribute named label into the NFSv4 file

Make that '... recommended attribute named "security_label"' ?

> +#define NFS4_MAXLABELLEN	4096

Idle curiosity--why 4096?  (Why couldn't it be 16?  And how do we know
people will never want 8192?)

> +#define NFSEXP_SECURITY_LABEL	0x0040  /* Support security label fattr4 */

I guess that answers my earlier question.

--b.
