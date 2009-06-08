From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 10:23:56 -0400
Message-ID: <200906081023.58679.vapier@gentoo.org>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <20090606160230.247d3ca3@tlielax.poochiereds.net> <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42667 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913AbZFHOX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 10:23:57 -0400
In-Reply-To: <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 08 June 2009 10:16:07 Chuck Lever wrote:
> Frankly, I think dropping back automatically is not a good idea.  The
> torrent of messages that configure normally spits out means that
> messages about a missing libtirpc are going to be missed in most
> cases, and folks will think that because they specified --enable-tirpc
> on the configure command line, that's the build they got.

the automatic fallback is when no tirpc option is specified.  if --enable-
tirpc is specified, then it should fail (and that is what the proposed patch 
does).
-mike
