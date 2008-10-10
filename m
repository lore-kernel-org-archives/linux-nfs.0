From: Michal Sojka <sojkam1-jQs2MHkdoM/twjQa/ONI9g@public.gmane.org>
Subject: Re: Case sensitivity in NFS files
Date: Fri, 10 Oct 2008 08:38:46 +0200
Message-ID: <200810100838.46687.sojkam1@fel.cvut.cz>
References: <200810091839.49445.sojkam1@fel.cvut.cz> <20081009183618.GA31168@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from max.feld.cvut.cz ([147.32.192.36]:52100 "EHLO max.feld.cvut.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbYJJGiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2008 02:38:51 -0400
In-Reply-To: <20081009183618.GA31168@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 09 of October 2008 20:36:18 J. Bruce Fields wrote:
> Do you know which filesystem it exports?  I haven't played with exports
> of case-insensitive filesystems, but the behavior you saw would seem
> consistent with that:

Thanks for your reply. Now I see you are right. The exported filesystem is 
ext3, so I expected it to be case sensitive, but if I check its behavior form 
the shell on NAS machine it behaves as case insensitive. Probably there is 
some patched kernel in the NAS machine. Unfortunately I do not have kernel 
sources, as they ship them only for $20 on CD by snail mail.

So this explains the observed behavior. Thanks again.

Michal S.
