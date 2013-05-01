Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:52863 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468Ab3EAM4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 May 2013 08:56:09 -0400
Date: Wed, 1 May 2013 08:56:02 -0400
From: Jim Rees <rees@umich.edu>
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Pseudoflavor 390004 not found!
Message-ID: <20130501125602.GA7738@umich.edu>
References: <5180DBCF.8070303@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <5180DBCF.8070303@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Toralf Förster wrote:

  2013-05-01T10:22:55.613+02:00 trinity kernel: gss_create: Pseudoflavor 390004 not found!
  2013-05-01T10:22:55.613+02:00 trinity kernel: RPC: Couldn't create auth handle (flavor 390004)

I think that means you're trying to use krb5 but don't have the gss_krb5
module loaded. If you really do want to use krb5, check your kernel
config. If not, check your mount options.
