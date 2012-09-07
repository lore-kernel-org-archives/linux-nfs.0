Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:57388 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756698Ab2IGBgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 21:36:25 -0400
Date: Thu, 6 Sep 2012 21:36:15 -0400
From: Jim Rees <rees@umich.edu>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered writes
Message-ID: <20120907013615.GA20444@umich.edu>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1346961251-2554-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

andros@netapp.com wrote:

  From: Andy Adamson <andros@netapp.com>
  
  This patch set is a Request for Comments: I think it does a fair job of
  handling the issue - but it is complicated, and other brains might find a
  better way to get the job done.

I really like it.  What we're doing now is nuts.  It even (mostly) solves
the old afs problem of write succeeding then having the close fail.
