Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38488 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbdFHOzU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 10:55:20 -0400
Date: Thu, 8 Jun 2017 10:55:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: devzero@web.de
Cc: linux-nfs@vger.kernel.org, pf@artcom-gmbh.de, rnews@altium.nl,
        jlayton@redhat.com
Subject: Re: Re: How to avoid rebooting Linux NFS-client when NFS-server is
 not available?
Message-ID: <20170608145518.GA8349@fieldses.org>
References: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
 <20170608133423.GG26995@fieldses.org>
 <trinity-7226e167-068f-4dac-bbe6-baecf1666bc3-1496930792511@3capp-webde-bap44>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <trinity-7226e167-068f-4dac-bbe6-baecf1666bc3-1496930792511@3capp-webde-bap44>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 08, 2017 at 04:06:32PM +0200, devzero@web.de wrote:
> > Ripping out the storage from underneath your applications is a pretty
> > drastic step and may lose data,
> 
> We did not rip out our storage, it`s still there and reachable without problems. Our hung nfs is NEVER being caused by nfs server reboots or poweroff, it seems to happen on network disruption or whatever.

OK, sounds like there's some other bug causing the original hang then, I
don't know what that is.

--b.
