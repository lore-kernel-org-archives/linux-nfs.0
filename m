Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:46868 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932732Ab2B2OEo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Feb 2012 09:04:44 -0500
Message-ID: <4F4E306C.6030400@steve-ss.com>
Date: Wed, 29 Feb 2012 15:04:28 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
References: <4F45E78E.8050501@steve-ss.com> <20120223063913.5736a5b1@tlielax.poochiereds.net> <4F4628B8.90401@steve-ss.com> <20120223144053.GA25010@fieldses.org> <4F465C3A.9080802@steve-ss.com> <20120223154215.GA26706@fieldses.org> <4F466467.3030506@steve-ss.com> <4F489999.30909@steve-ss.com> <20120228200524.GE2723@fieldses.org> <4F4D61B6.5090304@steve-ss.com> <20120229124401.GA9160@fieldses.org>
In-Reply-To: <20120229124401.GA9160@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/02/12 13:44, J. Bruce Fields wrote:
> On Wed, Feb 29, 2012 at 12:22:30AM +0100, steve wrote:
>> We are authenticating against Samba4, so our domain user accounts
>> are under Kerberos.
>
> Kerberos works fine with v3.
>
> --b.

Hi
Unfortunately, it doesn't seem to. We just tried it, and anyone (with or 
without a ticket) gets access:-(
Still hoping!
Steve

