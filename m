Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59272 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbCTOxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2015 10:53:53 -0400
Date: Fri, 20 Mar 2015 14:53:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org, etmsys@rit.edu,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: fix BUG() crash in notify_change() with patch to
 chown_common()
Message-ID: <20150320145351.GZ29656@ZenIV.linux.org.uk>
References: <1424699484-74025-1-git-send-email-aweits@rit.edu>
 <20150223205435.GA28635@fieldses.org>
 <m2iodvivzk.fsf@discipline.rit.edu>
 <20150320145013.GB2036@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150320145013.GB2036@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 20, 2015 at 10:50:13AM -0400, J. Bruce Fields wrote:
> On Fri, Mar 20, 2015 at 10:28:31AM -0400, Andrew W Elble wrote:
> > 
> > Any update/feedback?
> 
> If you haven't already: could you resend it, To: Al, and a "Cc:
> stable@vger.kernel.org" line?

It's in the local queue; will push when I reorder it tonight...
