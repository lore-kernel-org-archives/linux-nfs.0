Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47385 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab1BWTja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 14:39:30 -0500
Date: Wed, 23 Feb 2011 14:39:29 -0500
To: Ferenc Wagner <wferi@niif.hu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Seemingly inconsistent directory state under NFSv4
Message-ID: <20110223193929.GA13399@fieldses.org>
References: <87sjvuiwnl.fsf@tac.ki.iif.hu>
 <87d3mkhvgb.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87d3mkhvgb.fsf@tac.ki.iif.hu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 22, 2011 at 05:42:44PM +0100, Ferenc Wagner wrote:
> Ferenc Wagner <wferi@niif.hu> writes:
> 
> > In our somewhat mixed NFSv4 setup (Linux 2.6.32 Debian squeeze server, a
> > 2.6.26 and a 2.6.32 Debian lenny client) we sometimes experience the
> > following: removing a file on the 2.6.26 client makes that file
> > disappear from the directory listing of the 2.6.32 client, but the file
> > itself remains accessible by its old -- now nonexistent -- name there.
> > Is such a confusing state expected, or is this the manifestation of some
> > bug?
> 
> Is this perhaps a manifestation of the following paragraph of
> nfs41-server.txt in the Linux kernel documentation?
> 
>     Incomplete delegation enforcement: if a file is renamed or
>     unlinked, a client holding a delegation may continue to
>     indefinitely allow opens of the file under the old name.
> 
> If yes, is there a way to list the active delegations (on the server and
> on the client) and possibly trigger releasing/recalling them?

The linux client will return any delegation before it does a rename or
unlink, so if you're just doing everything from one client, I don't
*think* the problem is with delegations--you should hit this delegation
problem only in the case where you are removing the file on one client
while using it on another, or removing on the server while using it on
the client.

(In the case of client-client conflicts, this is fixed in 2.6.38.)

You can turn off delegations completely with

	echo 0 >/proc/sys/fs/leases-enable

before starting the nfs server.

--b.
