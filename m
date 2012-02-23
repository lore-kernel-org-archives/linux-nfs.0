Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36581 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab2BWTmH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 14:42:07 -0500
Received: by ghrr11 with SMTP id r11so810761ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 11:42:06 -0800 (PST)
Message-ID: <4F46968C.80009@tonian.com>
Date: Thu, 23 Feb 2012 11:42:04 -0800
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.2-2012-02-22
References: <4EC13EEA.3030404@tonian.com> <4EDBACDD.3010609@tonian.com> <4F0A9F00.4020308@tonian.com>
In-Reply-To: <4F0A9F00.4020308@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches were committed to the pnfs-all-3.2 branch at pnfs-all-3.2-2012-02-22
since last update (pnfs-all-3.2-2012-01-08):

  Boaz Harrosh     dfa1c05 pnfsd-exofs: Fix the RAID5 export
  Benny Halevy     0a93004 nfsd41: add missing break when encoding op_why_no_deleg
  Benny Halevy     b2ccd04 pnfsd: add support for per-file layout_types attribute
  Mi Jinlong       3ffa935 nfsd41: allow non-reclaim open-by-fh's in 4.1
