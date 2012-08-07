Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46387 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab2HGPlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 11:41:15 -0400
Date: Tue, 7 Aug 2012 11:41:14 -0400
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120807154114.GA21460@fieldses.org>
References: <20120806135517.GS25979@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120806135517.GS25979@ics.muni.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 06, 2012 at 03:55:17PM +0200, Lukas Hejtmanek wrote:
> it seems that RHEL NFSv4 servers use GSS authentication for backchannels as
> well (if mount it with GSS). That would be OK, but it requires that server is
> running rpc.gssd and the client is running rpc.svcgssd, which is not usual.

The init scripts probably need to be fixed to start both in both cases.
Worth filing a bug, I think.

> Is there a way how to mount clients with sec=krb5/i/p and use backchannels just
> with UNIX auth?

Not with NFSv4; from http://www.ietf.org/rfc/rfc3530.txt section 3.4:

	"Except as noted elsewhere in this section, the callback RPC
	(described later) MUST mutually authenticate the NFS server to
	the principal that acquired the clientid (also described later),
	using the security flavor the original SETCLIENTID operation
	used."

(Actually, perhaps there's a loophole that would allow SETCLIENTID to be
done with auth_sys while file access is still done with gss.  I don't
think so, but I forget the details.  In practice the clients do all use
gss.)

4.1 does allow the client to request a different security flavor on the
backchannel, and the linux client does use auth_sys on the backchannel
even when using gss on the forechannel.

--b.
