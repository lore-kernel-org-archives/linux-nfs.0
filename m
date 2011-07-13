Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab1GMW7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 18:59:40 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Qh8P6-0003hV-1f
	for linux-nfs@vger.kernel.org; Wed, 13 Jul 2011 18:59:40 -0400
Date: Wed, 13 Jul 2011 18:59:39 -0400
To: linux-nfs@vger.kernel.org
Subject: krb5 failures with recent nfs-utils
Message-ID: <20110713225939.GA13000@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fedora 15 I'm seeing odd krb5 behavior: the context initialization
appears to work fine, but then gssd sends a malformed RPCSEC_GSS_DESTROY
packet just before closing the connection.  The client's first operation
to the server using the context is rejected because the server's mic
verification fails.

Has anyone else seen this?

I'll keep investigating.

--b.
