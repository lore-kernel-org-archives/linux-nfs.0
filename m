Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from master.debian.org ([70.103.162.29]:40618 "EHLO
	master.debian.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890Ab1FIByd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 21:54:33 -0400
Date: Thu, 9 Jun 2011 11:37:56 +1000
From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
To: Sam Hartman <hartmans@debian.org>
Cc: Kevin Coffman <kwc@citi.umich.edu>, Didier Raboud <odyx@debian.org>,
        linux-nfs@vger.kernel.org, 629553@bugs.debian.org,
        629692@bugs.debian.org
Subject: Re: libgssglue: incompatible with krb5 1.9
Message-ID: <20110609013756.GA5304@master.debian.org>
References: <tsl1uz57fa1.fsf@mit.edu>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <tsl1uz57fa1.fsf@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 07, 2011 at 12:55:02PM -0400, Sam Hartman wrote:
>
>package: libgssglue-dev
>severity: serious
>justification: package breaks nfs-utils build
>version: 0.2-2
>
>Hi, Kevin and Debian maintainers:
>
>In an upcoming release, MIT has started adopting the new GSS-API type
>names at the top of page 12 of RFC 5587.
>
>
>For a variety of reasons, I pulled this change into Debian unstable.
>Unfortunately, some applications such as nfs-utilsappear to pull in
>gssapi.h from libgssglue, but pull in gssapi_ext.h from krb5.
>
>This does not work unless the gssapi.h from libgssglue includes the new
>constant type names.
>
>--Sam

Kevin,

The original bug report #629553 is available at
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629553

and bug report #629692 (which has build logs) is available at
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629692

Sam,

Could you please post the unified diff of gssapi.h from libgssglue that
makes it work?

Cheers,

Aníbal
