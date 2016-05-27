Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.sciencehorizons.net ([71.41.210.147]:32301 "HELO
	ns.sciencehorizons.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1756334AbcE0Rvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 13:51:47 -0400
Date: 27 May 2016 13:14:12 -0400
Message-ID: <20160527171412.20981.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
To: bfields@fieldses.org, linux@sciencehorizons.net
Subject: I may be on the trail of that bug you hit...
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
In-Reply-To: <20160527121632.GC25272@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> But... the resulting kernel isn't booting succesfully for me.  Not sure
> what's up there, I'll investigate some more.

On a 32-bit machine, a listing of /proc shows self, but stat /proc/self
returns ENOENT.  Very odd, am investigating.  Thank you again for
catching things I managed to miss, I've since found several glitches.
