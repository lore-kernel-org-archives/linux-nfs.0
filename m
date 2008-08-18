From: Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>
Subject: NFS regression?  Odd delays and lockups accessing an NFS export.
Date: Mon, 18 Aug 2008 12:02:20 +1000
Message-ID: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay04.mail-hub.dodo.com.au ([123.2.6.239]:48148 "EHLO
	relay04.mail-hub.dodo.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbYHRCDE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Aug 2008 22:03:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi there,

I've been using NFS here for years, lately there's something odd going on 
since about a month or so.  Previously reported last month:
http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last

Now with 2.6.27-rc3 on one of the client boxes I get a complete stall 
at odd times when accessing the server's exported directory, cannot 
see a pattern to it.  Eventually recovers after a Ctrl-C.  Nothing in 
the server or client log files.  Not easy to reproduce either.

The server runs 2.6.26.2 at the moment.

Server config, etc: http://bugsplatter.id.au/kernel/boxen/deltree/
Client config, etc: http://bugsplatter.id.au/kernel/boxen/pooh/

Grant.
