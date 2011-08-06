Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:48281 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab1HFHlQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:16 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Manpage syntax fixes
Date: Sat,  6 Aug 2011 09:41:13 +0200
Message-Id: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi

Following are a couple of patches fixing manpage syntax warnings and errors:

[PATCH 1/6] exports.man: "\* d lets man complain
[PATCH 2/6] nfs.man: man complains when line starts with quote
[PATCH 3/6] statd.man: man complains about lines starting with '
[PATCH 4/6] nfsiostat.man: Fix missing I in ".I <interval>"
[PATCH 5/6] exports.man: Fix comment syntax
[PATCH 6/6] nfs.man: Fix macro use for fstab examples

Cheers

Luk
