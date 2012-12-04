Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab2LDM6t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:49 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1Tfs5J-0004pp-98
	for linux-nfs@vger.kernel.org; Tue, 04 Dec 2012 07:58:49 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: server support for multiple tcp fragments
Date: Tue,  4 Dec 2012 07:58:41 -0500
Message-Id: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wanted to use pynfs to reproduce a bug with the server's handling of
certain large compounds, but ran into trouble because pynfs likes to
break up rpc's into 2k fragments.  Rather than fixing pynfs I decided
it's long past time we should have fixed this bug in the server....

I'm planning to queue this up for 3.8.--b.

