Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:37412 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbaE0XVk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2014 19:21:40 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WpQga-0005UG-MT
	for linux-nfs@vger.kernel.org; Wed, 28 May 2014 01:21:36 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 01:21:36 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 01:21:36 +0200
To: linux-nfs@vger.kernel.org
From: Jaap <jwinius@umrk.nl>
Subject: Re: NFSv4 with Kerberos and no_root_squash
Date: Tue, 27 May 2014 23:21:24 +0000 (UTC)
Message-ID: <lm36lj$bbb$1@ger.gmane.org>
References: <llqgta$3d3$1@ger.gmane.org>
	<20140527205407.GB32160@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 May 2014 16:54:07 -0400, J. Bruce Fields wrote:

> You may want to look at "Credentials for UID 0" in the rpc.gssd man
> page?

If you mean that I should run rpc.gssd with the "-n" option, in that case 
I still get "Permission denied" when attempting to write to one of the 
"no_root_squash" exports as root. I even tried using the machine 
credentials "root/<hostname>@<REALM>" instead of "host/..." , but to no 
avail.

Thanks anyway,

Jaap

