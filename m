Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093Ab2IQPy2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 11:54:28 -0400
Date: Mon, 17 Sep 2012 11:54:26 -0400
To: Trond Myklebust <trond@netapp.com>, Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: readdir cookies
Message-ID: <20120917155426.GK30673@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How does the nfs client decide what directory cookies to return?  (As
the d_off field to readdir, for example).

I'd assumed it would return the server's cookie, but testing shows it
returns a simple integer sequence.

--b.
