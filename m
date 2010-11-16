Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754716Ab0KPSaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 13:30:52 -0500
Date: Tue, 16 Nov 2010 13:30:50 -0500
To: Valentijn Sessink <valentyn@blub.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: no_root_squash (and valid KRB root-ticket)
Message-ID: <20101116183050.GC3971@fieldses.org>
References: <4CE294DD.6010508@blub.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CE294DD.6010508@blub.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 16, 2010 at 03:27:41PM +0100, Valentijn Sessink wrote:
> Hello list,
> 
> I found that having "no_root_squash" on the server, having a valid
> Kerberos ticket for root@DOMAIN, does still not give you root rights on
> a share. Looking further, I found
> http://www.unix-info.org/nfsV4_howto_.txt that says that there is "no
> proper mapping between root and the GSSAuthName"; but I could not find
> the status of this document.
> 
> Could any of you comment on this? Is this still the case (I suppose so)?

This is between a linux client and server?

Are other kerberos principals mapped as you'd expect?

I don't recall the code treating root specially, but I haven't checked.

--b.
