Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-1.concepts.nl ([213.197.30.124]:53747 "EHLO
	smtp-1.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab1JYWAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Oct 2011 18:00:31 -0400
Received: from d594e6a3.dsl.concepts.nl ([213.148.230.163] helo=gnome.loos.site)
	by smtp-1.concepts.nl with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RIp2p-0005uf-7J
	for linux-nfs@vger.kernel.org; Wed, 26 Oct 2011 00:00:27 +0200
Received: from [172.22.21.203] (helo=neminis.intra.loos.site)
	by gnome.loos.site with esmtp (Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RIp2o-0004pZ-Fp
	for linux-nfs@vger.kernel.org; Wed, 26 Oct 2011 00:00:26 +0200
Date: Wed, 26 Oct 2011 00:00:25 +0200
From: Arno Schuring <aelschuring@hotmail.com>
To: linux-nfs@vger.kernel.org
Subject: Re: sec=krb5 mounts never return
Message-ID: <20111026000025.64f1e215@neminis.intra.loos.site>
In-Reply-To: <20111021012327.612839b5@neminis.loos.site>
References: <20111021012327.612839b5@neminis.loos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Arno Schuring (aelschuring@hotmail.com on 2011-10-21 01:23 +0200):
> Hello list,
> 
> tl;dr: mount calls with sec=krb5 never return. They appear to get
> stalled in the kernel on "svc: transport is dead". I need to know
> if this is a configuration issue, a kernel problem or a userland
> problem, and how it can be resolved.

This appears to have been reported two months ago against Debian:
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=638157

And fixed over a year ago on this list:
http://www.spinics.net/lists/linux-nfs/msg14723.html


It's a wonderful world, isn't it?

Best wishes,
Arno
