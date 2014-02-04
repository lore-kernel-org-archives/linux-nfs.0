Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52118 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201AbaBDSyx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 13:54:53 -0500
Date: Tue, 4 Feb 2014 13:54:50 -0500
To: Anthony Messina <amessina@messinet.com>
Cc: Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140204185450.GA12324@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
 <20140204093452.7b6d7c7d@notabene.brown>
 <52F130E2.6090308@RedHat.com>
 <39783294.8Mk3atqdZo@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <39783294.8Mk3atqdZo@linux-ws1.messinet.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 04, 2014 at 12:48:47PM -0600, Anthony Messina wrote:
> On Tuesday, February 04, 2014 01:26:42 PM Steve Dickson wrote:
> > > Also rpc.gssd will be run whenever nfs-server.target or nfs-client.target
> > > is started.
> > 
> > Why is rpc.gssd started when the nfs server is started? Possibly for secure 
> > loopback mounts??
> 
> Isn't this needed for KRB5/NFSv4.1 callbacks?  I seem to remember needing this 
> on the server as well as the client, lest I get the frequent "gss upcall 
> timeout" issue.  At least on Fedora that's how it's been for me.

It's only for KRB5/NFSv4.0 callbacks, actually.  Since minor version >=1
callbacks use the client-established credentials (and the
client-established tcp connection).

--b.
