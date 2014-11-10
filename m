Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:37309 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbaKJCMw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2014 21:12:52 -0500
Date: Mon, 10 Nov 2014 13:12:48 +1100
From: Dave Chinner <david@fromorbit.com>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141110021248.GQ28565@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414775040-4051-2-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 01, 2014 at 01:03:56AM +0800, Eryu Guan wrote:
> This commit disables tests requires scratch dev running on NFS
> 
> c041421 xfstests: stop special casing nfs and udf
> 
> Now re-enable them to get a larger test coverage on NFS.
> 
> Signed-off-by: Eryu Guan <eguan@redhat.com>

I'll commit this as is, but can you send another patch to wire this
same functionality up for CIFS?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
