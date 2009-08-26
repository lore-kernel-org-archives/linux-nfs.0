Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:6789 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755531AbZHZE7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 00:59:23 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.112])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n7Q4xMaV014266
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 21:59:22 -0700
Message-ID: <4A94C129.2050308@dreamworks.com>
Date: Tue, 25 Aug 2009 21:59:21 -0700
From: Lans Carstensen <Lans.Carstensen@dreamworks.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the reworked patchset for nfs-iostat.py, separating out:
* the python path change
* the version bump due to adding a feature
* the autofs mountpoint add/drop rescanning
* the --sort and -<n> features

Thanks again for considering this.

-- Lans Carstensen, Systems Engineering, Dreamworks Animation
Because they consistently observe and listen, the humble improve.
                                                -- Wynton Marsalis



