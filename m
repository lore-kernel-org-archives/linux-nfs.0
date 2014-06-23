Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:47232 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888AbaFWN4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 09:56:08 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id CC77D2803A3
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:05 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 9E3A810D9
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 15:56:05 +0200 (MEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: beatify pynfs and CI integration 
Date: Mon, 23 Jun 2014 15:56:01 +0200
Message-Id: <1403531763-13441-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two small patches:

One allows to map nfs requests to pynfs tests based on tags.
Second groups test results by test module, which makes generated
output to look like regular junit report. This nicely fits into
any modern CI system.

