From: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Problem with 2.6.33-rc1 and insecure flag
Date: Sun, 20 Dec 2009 02:52:09 +0100
Message-ID: <20091220015209.GA1577@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:56380
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754773AbZLTB65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Dec 2009 20:58:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am testing 2.6.33-rc1 on my nfs server here and I noticed a problem
with macosx clients.

Commit 12045a6ee9908b38b6d286530c7d816e39071346
nfsd: let "insecure" flag vary by pseudoflavor

seems to be the problem. For macosx clients you need to specify the
insecure flag since they try to mount with a high port per default. This
commit somehow turns the logic around. If I specify insecure I can ONLY
mount the export if I use a port <= 1023. Reverting the commit fixes the
problem for me.

Kind regards,
Michael Guntsche
