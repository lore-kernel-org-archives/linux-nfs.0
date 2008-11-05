From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/18] kernel NSM support for IPv6 (take 2)
Date: Wed, 5 Nov 2008 15:45:17 -0500
Message-ID: <20081105204517.GC1455@fieldses.org>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net> <20081105194955.GA1455@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46602 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbYKEUpT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:45:19 -0500
In-Reply-To: <20081105194955.GA1455@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 02:49:55PM -0500, bfields wrote:
> By the way, I did some miscellaneous nsm cleanup a few months ago and
> never got around to sending it out.  I'll pass that along in a moment.

For which I meant to send out a cover letter and forgot, sorry!

Anyway, the first four patches are just small cleanup and bugfixing in
the same area.  The remaining patches split up the client's and server's
host lists into two separate tables.

They could all use another look-over and some testing; just thought you
might be interested as long as you're in the neighborhood.

Also todo in vaguely the same area:
	- nlmsvc_invalidate_all should be done on nfsd shutdown, but
	  we're doing shutdown per transport for some reason, which
	  seems dumb.  So fix that reference counting so there's just
	  one count for the whole server.
	- it would be nice to be able to shutdown the server
	  independently of the client; currently there's no way to do
	  that, as there's no way for sm-notify to distinguish client
	  from server hosts.  (There may be no solution in the case
	  where a single host has both client and server relationships
	  with us--but people probably shouldn't be doing that anyway
	  (it seems deadlock prone.)
	- the debugging code in nlm_shutdown_hosts() may be overkill.

--b.
