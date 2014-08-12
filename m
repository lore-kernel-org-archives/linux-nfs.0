Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38766 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417AbaHLSTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 14:19:42 -0400
Date: Tue, 12 Aug 2014 14:19:41 -0400
To: Ben H <bhendin@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Fwd: question re: NO_AUTH_DATA_REQUIRED
Message-ID: <20140812181941.GA25197@fieldses.org>
References: <CAAd7aua8+U=eFZUFhjp8gcnYv9BkvjOgSbLJbGp_Qg9O5cHH5w@mail.gmail.com>
 <CAAd7auZOmk4_tR0WnqFCbv3CSLF=BXoQjtdsQZaB0dgoOYNREw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAAd7auZOmk4_tR0WnqFCbv3CSLF=BXoQjtdsQZaB0dgoOYNREw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2014 at 01:23:38PM -0500, Ben H wrote:
> First off, apologies if this is not the correct list.
> I saw questions like this on the old nfsv4@linux-nfs.org list, and
> believe that this replaces that.
> Please direct me to a more appropriate resource if available.
> If I'm in the right place, I'm looking for some schooling...
> 
> I have been working with NFSv4 sec=krb5 and early on ran into the PAC
> issue described nebulously throughout various resources on the web.
> 
> When working with AD users who are in multiple groups (in my
> experiments, seems to be approximately 20) I have to set
> NO_AUTH_DATA_REQUIRED on the userAccountControl of my NFS server
> principal so that the PAC is not sent and the TGS-REQ can occur over
> UDP.
> 
> What I cannot find an answer for is why/where exactly is this
> limitation introduced?
> Kerberos can deal with the larger packets via TCP, and some Kerberos
> implementation may enforce TCP even on smaller packets.

The main problem is the kernel<->rpc.svcgssd interface.

The problem should be fixed on newer distros that use gss-proxy.

--b.
