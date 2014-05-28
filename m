Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:48324 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960AbaE1PIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 11:08:11 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WpfSa-0001dU-9L
	for linux-nfs@vger.kernel.org; Wed, 28 May 2014 17:08:08 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 17:08:08 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 17:08:08 +0200
To: linux-nfs@vger.kernel.org
From: Jaap <jwinius@umrk.nl>
Subject: Re: NFSv4 with Kerberos and no_root_squash
Date: Wed, 28 May 2014 15:07:54 +0000 (UTC)
Message-ID: <lm4u4a$tbn$1@ger.gmane.org>
References: <llqgta$3d3$1@ger.gmane.org>
	<20140527205407.GB32160@fieldses.org> <lm36lj$bbb$1@ger.gmane.org>
	<20140528140544.GB22210@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 May 2014 10:05:44 -0400, J. Bruce Fields wrote:

> Right, I'd expect that to be mapped to nobody.

Same here. But if I export a directory that is owned by nobody.nogroup, I 
still can't write to it as root.
 
> You can set up a one-off mapping for a given machine credential in
> idmapd.conf.  (If you're using rpc.svcgssd.  ...)

I am using rpc.svcgssd, but even if I add the following to idmapd.conf on 
both the server and the client (although I think it's only necessary on 
the server):

  [Static]
  root/<hostname>@<realm> = root

... I still get the same result when I try to write to one of the exports 
as root: Permission denied.

> ( ... If you're using gss-proxy I think there's similar
> configuration in /etc/krb5.conf.)

That would be the "auth_to_local" tag in the [Realms] section. The gss-
proxy project seems to be a RedHat effort to replace rpc.svcgssd. Perhaps 
not such a bad idea. However, I'm using Debian.

Thanks,

Jaap

