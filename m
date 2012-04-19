Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:60005 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753737Ab2DSLYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 07:24:39 -0400
Date: Thu, 19 Apr 2012 07:24:17 -0400
From: Jim Rees <rees@umich.edu>
To: Harald Dunkel <harald.dunkel@aixigo.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Howto temporarily disable delegation?
Message-ID: <20120419112417.GA12468@umich.edu>
References: <4F8FB4AA.602@aixigo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F8FB4AA.602@aixigo.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Harald Dunkel wrote:

  Is there some way to temporarily disable file delegation
  on the NFSv4 server?

I think it's "echo 0 >/proc/sys/fs/leases-enable" and you have to do it
before you start the server.
