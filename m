Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754300Ab1HZUoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 16:44:12 -0400
Date: Fri, 26 Aug 2011 16:44:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period
 expiration
Message-ID: <20110826204408.GD17196@fieldses.org>
References: <4E45C164.1070604@panasas.com>
 <20110826203924.GC17196@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110826203924.GC17196@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You also asked more generally what we could do to make the grace period
less obnoxious.  I have some minimal notes here:

	http://wiki.linux-nfs.org/wiki/index.php/Nfsd4_server_recovery#Nice_to_have

Making sure there are no v4 clients on its own doesn't do the job since
we also want consistency with NLM clients.  But the kernel doesn't
currently know about NLM clients.

I haven't come up with any bright ideas here yet.

--b.
