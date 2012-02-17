Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab2BQViP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 16:38:15 -0500
Date: Fri, 17 Feb 2012 16:38:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5] 4.1 server tests: add delegation_want tests
Message-ID: <20120217213814.GC2694@fieldses.org>
References: <4F3D47B3.1090708@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F3D47B3.1090708@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 08:15:15PM +0200, Benny Halevy wrote:
> [PATCH 1/5] 4.1 server tests: testReadDeleg recognize also OPEN_DELEGATE_NONE_EXT
> [PATCH 2/5] 4.1 server tests: move testReadDeleg from st_open to
> [PATCH 3/5] 4.1 server tests: testWriteDeleg
> 	Note: this test fails against the linux server

Yeah.  That might take a while, and our behavior is really legal, so it
might be better to turn that one off by default.  Anyway, for now...

> [PATCH 4/5] 4.1 server tests: testAnyDeleg
> [PATCH 5/5] 4.1 server tests: test NFS4_SHARE_WANT_NO_DELEG

... all applied.  Thanks!

--b.
