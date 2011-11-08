Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52015 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753552Ab1KHW5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 17:57:54 -0500
Date: Tue, 8 Nov 2011 17:57:51 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/25] nfsd4 state cleanup
Message-ID: <20111108225751.GD27413@fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 14, 2011 at 07:44:56AM -0400, J. Bruce Fields wrote:
> And then also still to do:
> 	- close replays: we keep around a stateid to handle close
> 	  replays only in the case where it's the last stateid for an
> 	  openowner, but that's not sufficient.
> 	- the data structures aren't really right for the things we need
> 	  to do: e.g. release_lockowner currently does a linear search
> 	  through all the lockowners!

OK, done, with the following patches, and that was the last thing on
this particular todo list.

I've also started a for-3.3 tree based on v3.2-rc1, including Bryan's
patches and some previous state code patches (not the following yet).

--b.

> 	- multiple client-to-lockowner locks for a given (owner, file)
> 	  aren't handled right.
> 	- I need to look again at doing a better job of distinguishing
> 	  the bad, expired, and stale cases for stateid's.
> 
> I was hoping to have that ready for 3.2 but unfortunately keep running
> across small bugs or cleanup opportunities like these along the way;
> perhaps next week....
