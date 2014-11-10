Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbaKJEFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2014 23:05:46 -0500
Date: Mon, 10 Nov 2014 12:05:36 +0800
From: Eryu Guan <eguan@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141110040536.GF2863@dhcp-13-216.nay.redhat.com>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
 <20141110021248.GQ28565@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141110021248.GQ28565@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2014 at 01:12:48PM +1100, Dave Chinner wrote:
> On Sat, Nov 01, 2014 at 01:03:56AM +0800, Eryu Guan wrote:
> > This commit disables tests requires scratch dev running on NFS
> > 
> > c041421 xfstests: stop special casing nfs and udf
> > 
> > Now re-enable them to get a larger test coverage on NFS.
> > 
> > Signed-off-by: Eryu Guan <eguan@redhat.com>
> 
> I'll commit this as is, but can you send another patch to wire this
> same functionality up for CIFS?

Sure, will do that.

Thanks,

Eryu
