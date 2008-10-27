From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Mon, 27 Oct 2008 10:58:43 +0100
Message-ID: <20081027095843.GA10937@squirrel.roonstrasse.net>
References: <20081022091207.GA12996@squirrel.roonstrasse.net> <20081023123628.GA18549@squirrel.roonstrasse.net> <1224773745.7625.4.camel@localhost> <20081024083913.GA15197@squirrel.roonstrasse.net> <1224871763.22672.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4.netcologne.de ([194.8.194.137]:41670 "EHLO
	smtp4.netcologne.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbYJ0J6q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2008 05:58:46 -0400
In-Reply-To: <1224871763.22672.33.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008/10/24 20:09, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> OK, could you please describe your environment a bit. Do you have lots
> of different users logged in at the same time, or do you perhaps use
> newgrp or su to switch uid/gids a lot on your processes?
> I'm trying to see if there might be a reason for the lookup in the
> credcache being such a heavy duty operation in your setup.

It's a web server for shared hosting.  The web space is mounted via
NFSv3 from a NetApp.  There is a huge number of web sites on this
cluster.  All web sites are owned by the same UID, and the web server
runs as a different UID (read-only access).

Each time a CGI starts, its uid is changed to the one "owner" UID
(similar to mod_suexec, but there's only one UID for all customer
accounts).  Each time a CGI starts, its chroot (pivot_root) is
constructed with several bind mounts (in a separate namespace with
CLONE_NEWNS).

There are no new users or groups being created.  There are only 2 UIDs
accessing NFS: the webserver (ro) and CGI (rw).

Max
