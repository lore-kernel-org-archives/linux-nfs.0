Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43319 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2JARnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:43:52 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIk23-0007sA-Ky
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:43:51 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd: pin clients to 4.0/4.1
Date: Mon,  1 Oct 2012 13:43:46 -0400
Message-Id: <1349113428-30173-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches should prevent clients from mixing 4.0 and 4.1
compounds, closing out another minor 4.1 todo.  (Though it would
probably be a good idea to write some pynfs tests for some of these odd
cases.)

--b.

