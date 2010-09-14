Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab0INBJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Sep 2010 21:09:17 -0400
Date: Mon, 13 Sep 2010 21:08:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH] TESTS: fix DELEG9
Message-ID: <20100914010813.GD27200@fieldses.org>
References: <20100914010630.GC27200@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100914010630.GC27200@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 13, 2010 at 09:06:30PM -0400, bfields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> The new server doesn't have a recall callback setup, so will never send
> the delegreturn.  (Doing it by hand at the end as attempted here doesn't
> work well, as the open that precedes that final delegreturn needs the
> delegreturn before it can succeed.)
> 
> Also, we need to set c.cb_server for _verify_cb_occurred to get the
> correct count.
> 
> After this patch, the test passes against the Linux server.

This patch, plus the other fixes I need to get usable results against
the Linux server, are also available from

	git://linux-nfs.org/~bfields/pynfs.git

(and, for 4.1, at:

	git://linux-nfs.org/~bfields/pynfs41.git

).

--b.
