Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbaJ0WIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2014 18:08:49 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1XisT3-0000ex-2f
	for linux-nfs@vger.kernel.org; Mon, 27 Oct 2014 18:08:49 -0400
Date: Mon, 27 Oct 2014 18:08:49 -0400
To: linux-nfs@vger.kernel.org
Subject: wireshark
Message-ID: <20141027220848.GB32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been getting frequent crashes with the latest wireshark.  I think
it's fixed in:

	git://linux-nfs.org/~bfields/wireshark.git master

I'll probably try to add seek and allocate support while I'm there, and
pass it to wireshark upstream when I've got it better figured out.

--b.
