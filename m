Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59118 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693AbaGWTYf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 15:24:35 -0400
Date: Wed, 23 Jul 2014 15:24:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: beatify pynfs and CI integration
Message-ID: <20140723192434.GG9118@fieldses.org>
References: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 03:56:01PM +0200, Tigran Mkrtchyan wrote:
> Two small patches:
> 
> One allows to map nfs requests to pynfs tests based on tags.
> Second groups test results by test module, which makes generated
> output to look like regular junit report. This nicely fits into
> any modern CI system.

OK, applied.

--b.
