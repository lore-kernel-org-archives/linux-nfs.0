From: "Jesper Krogh" <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: NFS performance (Currently 2.6.20)
Date: Wed, 6 Feb 2008 11:04:34 +0100 (CET)
Message-ID: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:33269 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbYBFKj5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 05:39:57 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 0D5D83BF2B6
	for <linux-nfs@vger.kernel.org>; Wed,  6 Feb 2008 11:04:50 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bcnarTWB+WZJ for <linux-nfs@vger.kernel.org>;
	Wed,  6 Feb 2008 11:04:34 +0100 (CET)
Received: from mail.jabbernet.dk (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 9A7643BF212
	for <linux-nfs@vger.kernel.org>; Wed,  6 Feb 2008 11:04:34 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi.

I'm currently trying to optimize our NFS server. We're running in a
cluster setup with a single NFS server and some compute nodes pulling data
from it. Currently the dataset is less than 10GB so it fits in memory of
the NFS-server. (confirmed via vmstat 1).
Currently I'm  getting around 500mbit (700 peak) of the server on a
gigabit link and the server is CPU-bottlenecked when this happens. Clients
having iowait around 30-50%.

Is it reasonable to expect to be able to fill a gigabit link in this
scenario? (I'd like to put in a 10Gbit interface, but when I have a
cpu-bottleneck)

Should I go for NFSv2 (default if I dont change mount options) NFSv3 ? or
NFSv4

NFSv3 default mount options is around 1MB for rsize and wsize, but reading
the nfs-man page, they suggest setting them "up to" around 32K.

I probably only need some pointers to the documentation.

Thanks.
-- 
Jesper Krogh

