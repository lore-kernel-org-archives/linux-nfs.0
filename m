Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:59806 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157AbcDFXJe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2016 19:09:34 -0400
Received: from smtp6-g21.free.fr (smtp6-g21.free.fr [212.27.42.6])
	by smtpfb1-g21.free.fr (Postfix) with ESMTP id D571477CD53
	for <linux-nfs@vger.kernel.org>; Thu,  7 Apr 2016 01:09:26 +0200 (CEST)
Received: from desktop.geekdomain (unknown [78.218.216.2])
	by smtp6-g21.free.fr (Postfix) with ESMTP id E8B3782257
	for <linux-nfs@vger.kernel.org>; Thu,  7 Apr 2016 01:05:22 +0200 (CEST)
Date: Thu, 7 Apr 2016 01:09:27 +0200
From: YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net>
To: linux-nfs@vger.kernel.org
Subject: Sometimes all the applications using sqlite do not work correctly
Message-Id: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am using nfs-utils-1.2.8 and sqlite-3.7.17 on Slackware 14.1.
Sometimes, all the applications using sqlite do not work correctly.

These applications are:
 * mozilla-firefox-44.0
 * mumble-1.2.8
 * xmoto-0.5.11

On mozilla-firefox, my bookmarks menu is empty.
On mumble, my favorite server list is empty.
On xmoto, the game could not run.

All these applications at the same time do not work and I need to restart the NFS server in order to be able to use these programs.

I don't know what could be the cause but I know that I have recently upgraded a lot of programs on my operating system (binutils-2.26, gcc-5.3.0, ...).

I am using NFS since many years (at least 4) and I have never get troubles with my applications using sqlite.

So, I am wondering what happens.

Should I rebuild nfs-utils?

Thank you.
Best regards.
