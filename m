From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 13:59:00 -0400
Message-ID: <1248199140.21343.17.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
	 <1248196339.21343.8.camel@heimdal.trondhjem.org>
	 <4A65FCB2.6080903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35714 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbZGUR7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 13:59:04 -0400
In-Reply-To: <4A65FCB2.6080903@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-21 at 10:36 -0700, Ben Greear wrote:
> On 07/21/2009 10:12 AM, Trond Myklebust wrote:
> > On Tue, 2009-07-21 at 09:49 -0700, Ben Greear wrote:
> >> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
> >>
> >>> What does /var/lib/nfs/v4recovery look like on the server?
> >> The server was misconfigured, but I still think the client should
> >> behave better in this case.  If you cannot reproduce it, let me know
> >> and I can try to be more specific.  If you still want the v4recovery
> >> information, let me know and I'll send it.
> >
> > So how should the client behave, when a screwed up server allows it to
> > mount but starts returning illegal values for setclientid? The only
> > thing I can see we could do is to tell the user EINSANESERVER...
> 
> Well, it could just fail the mount and give up and not overly spam
> /var/log/messages in a tight loop perhaps?

This doesn't happen at mount time. It happens when you open a file.

Trond

