From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Get rid of empty AUTHORS file
Date: Sat, 18 Oct 2008 20:48:11 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0810182047070.17929@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:59066 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbYJSAsN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2008 20:48:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id BB39A1C0989E2
	for <linux-nfs@vger.kernel.org>; Sat, 18 Oct 2008 20:48:11 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


the AUTHORS file reads:

	This is a dummy AUTHORS file to make automake happy.

You can make automake happy in an IMO better way:

	AUTOMAKE_OPTIONS = foreign

at the top of the toplevel Makefile.am.
(I usually also prefer "AUTOMAKE_OPTIONS = subdir-objs" next to 
foreign.)
