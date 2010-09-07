From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Date: Tue, 7 Sep 2010 01:13:36 -0400
Message-ID: <20100907051336.GC14584@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401Ab0IGFOV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 01:14:21 -0400
In-Reply-To: <20100907051241.GB14584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After those two patches I can finally pass connectathon tests on 2.6.36.
(Argh.)

--b.
