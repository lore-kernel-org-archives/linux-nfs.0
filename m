From: devzero-S0/GAf8tV78@public.gmane.org
Subject: inotify and nfsd exported filesystem
Date: Tue, 22 Jan 2008 21:26:24 +0100
Message-ID: <120329353@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate05.web.de ([217.72.192.243]:52156 "EHLO
	fmmailgate05.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbYAVU00 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2008 15:26:26 -0500
Received: from web.de
	by fmmailgate05.web.de (Postfix) with SMTP id 223513CC9646
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jan 2008 21:26:25 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hello !

it seems that accessing a file via knfsd exported filesystem doesn`t create an appropriate event with inotify-tools, i.e. i cannot "see" that this file has been accessed.
no problems if acess that file on the same machine via userspace - but accessing from a remote box via nfs just fails.

can somebody confirm this issue?

is this by design or is this a bug?

regards
roland
_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=100071&distributionid=000000000066

