Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55011 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab1BXR1s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Feb 2011 12:27:48 -0500
Date: Thu, 24 Feb 2011 12:27:47 -0500
To: Ferenc Wagner <wferi@niif.hu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Seemingly inconsistent directory state under NFSv4
Message-ID: <20110224172747.GA22070@fieldses.org>
References: <87sjvuiwnl.fsf@tac.ki.iif.hu>
 <87d3mkhvgb.fsf@tac.ki.iif.hu>
 <20110223193929.GA13399@fieldses.org>
 <87vd098jk5.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87vd098jk5.fsf@tac.ki.iif.hu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

By the way, could you configure your mail client not to drop me (or
others) off the cc:?  Those of us that subscribe to a lot of high-volume
kernel lists generally treat mail sent to us diferently from mail sent
to a list.

On Thu, Feb 24, 2011 at 05:48:58PM +0100, Ferenc Wagner wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> One client removed the file, and another could still access it by name
> (although not present in the directory listing).  So it could have been
> a client-client conflict, even though we couldn't prove that the removed
> file was actually in use on the client.  Is there a way to list the
> delegations being hold by a client?

Not really.  They'll show up as LEASE entries in /proc/locks, with the
pid of an nfsd process, but no way to associate them with a client.

Some way to dump lock (and other state) information might be a nice
thing to have some day for debugging and tuning.

> > You can turn off delegations completely with
> > 	echo 0 >/proc/sys/fs/leases-enable
> > before starting the nfs server.
> 
> Wouldn't I lose most of the efficiency advantages of NFSv4 with that
> move?

Probably so.  It would at least be a way to verify whether delegations
are the source of your problem, if you have a reproduceable test case.

--b.
