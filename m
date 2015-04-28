Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.astim.si ([93.103.6.239]:57915 "EHLO mail.astim.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030577AbbD1Qon (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 12:44:43 -0400
From: "Saso Slavicic" <saso.linux@astim.si>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <000601d080b0$687a2860$396e7920$@astim.si> <20150427151944.GA2735@fieldses.org>
In-Reply-To: <20150427151944.GA2735@fieldses.org>
Subject: RE: server_scope v4.1 lock reclaim
Date: Tue, 28 Apr 2015 18:44:27 +0200
Message-ID: <000101d081d2$984f1820$c8ed4860$@astim.si>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: J. Bruce Fields
> Sent: Monday, April 27, 2015 5:20 PM

> So in theory we could add some sort of way to configure the server scope
> and then you could set the server scope to the same thing on all your
> servers.
>
> But that's not enough to satisfy
> https://tools.ietf.org/html/rfc5661#section-2.10.4, which also requires
> stateid's and the rest to be compatible between the servers.

OK...I have to admit that with the amount of NFS HA tutorials and the
improvements that NFS v4(.1) brings in the specs, I assumed that HA failover
was supported. I apologize if that is not the case.

So, such a config option could be added but it's not planned to be added,
since it could be wrongly used in some situations (ie. not doing
active-to-passive failover)?
Active-active setup is then totally out of the question?

> In practice given current Linux servers and clients maybe that could
> work, because in your situation the only case when they see each other's
> stateid's is after a restart, in which case the id's will include a boot
> time that will result in a STALE error as long as the server clocks are
> roughly synchronized.  But that makes some assumptions about how our
> servers generate id's and how the clients use them.  And I don't think
> those assumptions are guaranteed by the spec.  It seems fragile.

I read (part of) the specs and stateids are supposed to hold over sessions
but not for different client ids.
Doing a wireshark dump, the (failover) server sends STALE_CLIENTID after
reconnect so that should properly invalidate all the ids?
Would I assume correctly that this is read from the nfsdcltrack? Is there
even a need for this database to sync between each failover, if the client
is already known since it's last failover (only the timestamp would be
older)?

> If it's simple active-to-passive failover then I suppose you could
> arrange for the utsname to be the same too.

I could, but then I don't know which server is active when I login to ssh :)
What would happen, if the 'migration' mount option would be modified for
v4.1 mounts not to check for server scope when doing reclaims (as opposed to
configuring server scope)? :)

Thanks,
Saso Slavicic

