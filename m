Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48246 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753498AbaI2Rz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 13:55:57 -0400
Date: Mon, 29 Sep 2014 13:55:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140929175555.GH30691@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <20140926183949.GC27412@fieldses.org>
 <20140926145446.21a99698@tlielax.poochiereds.net>
 <20140926194616.GE27412@fieldses.org>
 <20140927090458.62806936@synchrony.poochiereds.net>
 <20140929164425.GF30691@fieldses.org>
 <20140929131130.3ba5d987@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140929131130.3ba5d987@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2014 at 01:11:30PM -0400, Jeff Layton wrote:
> If there is any bug, I think it's only going to crop up under extremely
> rare circumstances -- network partitions cropping up during reclaims,
> multiple reboots, etc...
> 
> We probably ought to try and clarify this stuff for the spec (and our
> own implementations) but I don't think there's any cause for alarm...

Yes in this case I agree.

In general though reboot-recovery interoperability is hard to test and
bad documentation increases the chance we'll get it wrong.

(And these "edge cases" could also be more common that we expect: e.g.
if power failures come in clusters, and bring your switches down at
about the same time, could multiple-restarts-with-network-partitions be
the normal case?)

--b.
