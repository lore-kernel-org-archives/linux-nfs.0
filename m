Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbbJOTJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2015 15:09:47 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 252E1C0798E1
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 19:09:47 +0000 (UTC)
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t9FJ9kSj005623
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 15:09:46 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id t9FJ9kYl046379
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 15:09:46 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id t9FJ9kDF046378
	for linux-nfs@vger.kernel.org; Thu, 15 Oct 2015 15:09:46 -0400
Date: Thu, 15 Oct 2015 15:09:46 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Diskless client with NFSv4 root?
Message-ID: <20151015190945.GH49747@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is this something that is expected to work?  It pretty much deadlocks
during boot.  I took a vmcore... the oldest RPC task (and the one that
had the RPC transport locked) was a SETATTR that was waiting on an id
mapper upcall, and the first task in the sending RPC wait queue was the
OPEN of the /sbin/request-key program.

If I disable id mapping on the NFS server then it looks like it works...

-Scott
