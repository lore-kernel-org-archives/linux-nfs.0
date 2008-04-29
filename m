From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: lock reclaims outside grace period
Date: Tue, 29 Apr 2008 17:57:07 -0400
Message-ID: <20080429215707.GF26468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46665 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207AbYD2V5I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 17:57:08 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1Jqxox-0007e6-GG
	for linux-nfs@vger.kernel.org; Tue, 29 Apr 2008 17:57:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current lockd code appears to reject regular locks done during the grace
period, but not reclaims that come outside of the grace period.

(That's based on inspecting the code--I haven't run tests.)

That seems like an obvious bug.  (We're not giving the client any way to
determine whether conflicting locks might have been granted.)

Can we fix it, or is there a chance that people have been depending on
this behavior?  (Maybe for failing over to an already-active server??)

--b.
