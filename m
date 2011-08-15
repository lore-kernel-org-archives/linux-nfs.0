Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab1HOW3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:29:01 -0400
Date: Mon, 15 Aug 2011 18:28:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: open() of device special files
Message-ID: <20110815222859.GD32181@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110815212539.GA32181@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110815212539.GA32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 05:25:39PM -0400, J. Bruce Fields wrote:
> Confirmed the fix; I'll apply.

Also found some opportunity for cleanups while I was there, as follows.

--b.
