Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:39692 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621Ab1ANPTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 10:19:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by magus.merit.edu (Postfix) with ESMTP id 577E12256C9
	for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 10:19:47 -0500 (EST)
Received: from magus.merit.edu ([127.0.0.1])
	by localhost (magus.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ikDCJNbon0HW for <linux-nfs@vger.kernel.org>;
	Fri, 14 Jan 2011 10:19:47 -0500 (EST)
Received: from merit.edu (castelmezzano.citi.umich.edu [141.212.112.22])
	by magus.merit.edu (Postfix) with ESMTPSA id 21CAF2256C7
	for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 10:19:47 -0500 (EST)
Date: Fri, 14 Jan 2011 10:19:45 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: 4.1 no-pnfs mount option?
Message-ID: <20110114151945.GA21629@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is there some way (mount option?) I can ask the client to attempt a 4.1
(sessions) mount but do not use pnfs?
