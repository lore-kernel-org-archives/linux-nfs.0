Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbaBDNYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 08:24:30 -0500
Date: Tue, 4 Feb 2014 08:24:26 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Anthony Messina <amessina@messinet.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140204082426.449519bd@tlielax.poochiereds.net>
In-Reply-To: <1757036.O2OPYTypu1@linux-ws1.messinet.com>
References: <20140130172451.7a354ce4@notabene.brown>
	<52F003A1.3060908@RedHat.com>
	<1757036.O2OPYTypu1@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 04 Feb 2014 06:42:12 -0600
Anthony Messina <amessina@messinet.com> wrote:

> On Monday, February 03, 2014 04:01:21 PM Steve Dickson wrote:
> > This changes the current API... Today to enable/start this service 
> > today one does:
> > 
> >   systemctl enable nfs-server
> >   systemctl start nfs-server
> > 
> > which would change to:
> > 
> >   systemctl enable nfs-server.target
> >   systemctl start nfs-server
> > 
> > with the same daemons being started.
> > This changed will cause existing scripts to fail... 
> > I guess I don't see the point of having a .target file. 
> > 
> > How is rpc.svcgssd enabled? Since the .service file does
> > not have a [Install] section the systemctl enable rpc.svcgssd
> > fails.
> > 
> > Also how does gss-proxy come to play in all this? Maybe we 
> > just use  gss-proxy by default and retire rpc.svcgssd.
> 
> Usually just a quite listener (end-user & small-time sysadmin) on this ML...
> 
> +1 for gss-proxy by default (for Fedora anyway).  I've been using it 
> throughout F19 extensively in the KRB5/NFSv4.1 environment with great success.  
> I have nfs-secure-server.service "masked" via systemd to prevent it from being 
> started.
> 
> There seems to be only one strange issue I've come across with gss-proxy vs. 
> rpc.svcgssd: https://fedorahosted.org/gss-proxy/ticket/98.  This is with 
> regard to how access for the "nfsnobody" user is handled.  The ticket attempts 
> to show that with rpc.svcgssd, a host with host credentials and a user without 
> credentials can still access NFS shares with 0755 directories and 0644 files 
> (via the host credentials and mapped to the nfsnobody user).  With gss-proxy, 
> I had to create user credentials for kojibuilder@REALM because the access 
> wasn't allowed via the nfsnobody path.  I'm not sure if this is resolved, or 
> by design, etc.  But it is the only issue I've seen with gss-proxy vs. 
> rpc.svcgssd.
> 
> Thanks.  -A
> 

Please do open a bug at bugzilla.redhat.com for that and cc me on it.
We really do want to ensure that these sorts of corner-cases get
addressed.

-- 
Jeff Layton <jlayton@redhat.com>
