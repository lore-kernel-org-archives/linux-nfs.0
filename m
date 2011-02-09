Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:42400 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab1BIQ2k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 11:28:40 -0500
Date: Wed, 9 Feb 2011 11:28:38 -0500
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Message-ID: <20110209162838.GA21056@merit.edu>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
 <1297227351-15365-2-git-send-email-bfields@redhat.com>
 <20110209050118.GA2485@infradead.org>
 <20110209151402.GA13624@pad.home.fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110209151402.GA13624@pad.home.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:

  Agreed.  Those two lines were actually untouched by this patch, no
  matter what diff thinks--but I'm just as happy to fix it up while we're
  there; done.

I agree too, but "indent -linux" likes "static" on a line by itself, and
prefers it over "static void".  This is not the first time I've disagreed
with it, although I use it a lot.
