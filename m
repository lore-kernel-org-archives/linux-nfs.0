From: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH 0/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Date: Mon, 14 Sep 2009 21:57:30 -0700
Message-ID: <4AAF1EBA.4090207@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:11134 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751454AbZIOE5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 00:57:33 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.78])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n8F4vZ9g013555
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 21:57:36 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's the testest/reworked patchset for nfs-iostat.py, separating out:
* python path change for package dependency detection and LSB compliance
* Updating list of mount points each interval for autofs environments
* Introduce optparse and update usage/help to use it
* Adding --sort and --list=n options

Thanks in advance for reviewing this.

-- Lans Carstensen, Systems Engineering, Dreamworks Animation
Because they consistently observe and listen, the humble improve.
                                                -- Wynton Marsalis


