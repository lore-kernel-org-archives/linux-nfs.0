Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtareserve89.acsu.buffalo.edu ([128.205.6.188]:45050 "EHLO
	mtareserve1.acsu.buffalo.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751592AbcCHUve convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 15:51:34 -0500
Received: from localmailg.acsu.buffalo.edu (localmailg.acsu.buffalo.edu [128.205.4.25])
	by mtareserve1.acsu.buffalo.edu (Postfix) with ESMTP id A84E5DBAFCF
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 15:51:33 -0500 (EST)
Received: from localmailg.acsu.buffalo.edu (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 9B6A1E09AE
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 15:51:33 -0500 (EST)
Received: from localmailg.acsu.buffalo.edu (localhost [127.0.0.1])
	by localmailg.acsu.buffalo.edu (Postfix) with ESMTP id 68A96E09AF
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 15:51:33 -0500 (EST)
Received: from smtp.buffalo.edu (smtp4.acsu.buffalo.edu [128.205.5.229])
	by localmailg.acsu.buffalo.edu (Prefixe) with ESMTP id 67218E09AE
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 15:51:33 -0500 (EST)
Received: from [10.84.31.75] (dhcp012-018-075.wireless.buffalo.edu [69.12.18.75])
	(Authenticated sender: mvalites@buffalo.edu)
	by smtp.buffalo.edu (Postfix) with ESMTPSA id 6266FE1C011
	for <linux-nfs@vger.kernel.org>; Tue,  8 Mar 2016 15:51:33 -0500 (EST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Apple Message framework v1283)
Subject: Re: RH 7 nfs-utils update causes segfault
From: Mark Valites <mvalites@buffalo.edu>
In-Reply-To: <alpine.OSX.2.19.9992.1603081532310.78938@planck.local>
Date: Tue, 8 Mar 2016 15:51:33 -0500
Message-Id: <21B4AE1D-4318-4B8B-996F-00339E7A384B@buffalo.edu>
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org> <56DDABE2.3040204@buffalo.edu> <alpine.OSX.2.19.9992.1603071443060.66950@dhcp0201.cthon.org> <56DF0497.6090407@buffalo.edu> <alpine.OSX.2.19.9992.1603081319550.78938@planck.local> <56DF1C65.9090007@buffalo.edu> <alpine.OSX.2.19.9992.1603081406260.78938@planck.local> <56DF286F.3010704@buffalo.edu> <alpine.OSX.2.19.9992.1603081513100.78938@planck.local> <56DF35A1.1000007@buffalo.edu> <alpine.OSX.2.19.9992.1603081532310.78938@planck.local>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 8, 2016, at 3:37 PM, Benjamin Coddington wrote:

> OK, that's pretty certainly this bug:
> https://bugzilla.redhat.com/show_bug.cgi?id=1313090
> 
> You can add your email to the CC list there, and leave a comment stating
> you're hitting it as well.

Done.

> If you have Red Hat support, you can open a support case.

Although I know I specifically mentioned RHEL 7 originally, we're actually now an Oracle Linux shop (sorry...) - does opening a case with Oracle help at all? (I'm actually not 100% sure we have support with them either though.)

> The patch in that BZ should fix it up for you, or you can use the previous
> nfs-utils version until that BZ changes to CLOSED, at which time a fixed
> nfs-utils pacakge will be available.
> 
> Nice job working through gdb over email, and sorry for the trouble.

Thank you for your patience & walking me through it. I haven't touched gdb since college & they don't let me drink at work like I surely did last time I used it...

I'll probably stay at the previous nfs-utils version until a patch comes out & trickles down to Oracle Linux.

Thanks again!
-Mark