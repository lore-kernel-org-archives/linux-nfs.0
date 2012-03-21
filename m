Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45406 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754445Ab2CUTYv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:24:51 -0400
Date: Wed, 21 Mar 2012 15:24:49 -0400
To: Bryan Schumaker <bjschuma@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: krb5 failures in recent nfs-for-next
Message-ID: <20120321192448.GB11222@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have you been doing any krb5 testing?

I'm seeing the client crash as of nfs-for-next, and haven't been able to
get any debugging out of it so far.

--b.
