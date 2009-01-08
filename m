From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 00/14] sunrpc: Sunrpc cache cleanups and upcall rework
Date: Thu, 8 Jan 2009 14:52:00 -0500
Message-ID: <20090108195158.GA19312@fieldses.org>
References: <20090108082510.050854000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753777AbZAHTwL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 14:52:11 -0500
In-Reply-To: <20090108082510.050854000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2009 at 07:25:10PM +1100, Greg Banks wrote:
> These patches are a snapshot of in-progress work

That sounds suspiciously like "do not apply!".  I may as well queue up
the first 6 for 2.6.30, though?

> to fix problems with
> the sunrpc upcall mechanism which are triggered under load when using
> multi-threaded rpc.mountd.  These are currently a hot issue with one
> of SGI's customers (SGI PV988959).
> 
> The early patches in the series are cleanups with zero logic changes.
> 
> The patches have been lightly tested, by mounting and running the
> cthon04 tests.  They have not been shipped or used in the field.

OK, thanks.

--b.
