Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:49241 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755579Ab3HMHaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 03:30:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1V993M-0007Nn-3Y
	for linux-nfs@vger.kernel.org; Tue, 13 Aug 2013 09:30:04 +0200
Received: from adsl-71-135-103-32.dsl.pltn13.pacbell.net ([71.135.103.32])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 09:30:04 +0200
Received: from joe.lee by adsl-71-135-103-32.dsl.pltn13.pacbell.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 09:30:04 +0200
To: linux-nfs@vger.kernel.org
From: Joe Lee <joe.lee@musician.org>
Subject: Re: MDS setup
Date: Tue, 13 Aug 2013 07:23:42 +0000 (UTC)
Message-ID: <loom.20130813T090508-522@post.gmane.org>
References: <5202C154.6020907@musician.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was a ridiculously stupid oversight: I hadn't built the pnfs support in
the kernel.

I got things squared away by running "make menuconfig" and enabling "NFSv4.1
server support for Parallel NFS (pNFS) (DEVELOPER ONLY)" under

File systems --->

  Network File Systems --->

    NFS server support

      NFS server support for NFS version 4 (EXPERIMENTAL)

