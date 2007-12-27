From: Tom Tucker <tom@opengridcomputing.com>
Subject: new transport switch BUG_ON in svc_xprt.c
Date: Thu, 27 Dec 2007 14:43:25 -0600
Message-ID: <1198788205.17199.26.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:58641 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752217AbXL0Uhc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2007 15:37:32 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce:

I see that you are back. I have now been able to reproduce the BUG_ON
that Aime saw on the new code. I ran it over the holidays and when let
run long enough it eventually hit it.

I am testing what I think is the fix (left over XPT_BUSY clear in the
close path). If this works, then I'm ready with a new version of the
patchset based on your comments plus this bug fix. 

Are you ready for the next round?

Thanks,
Tom


