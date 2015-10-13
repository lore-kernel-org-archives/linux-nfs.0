Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:49226 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbbJMOeq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 10:34:46 -0400
Date: Tue, 13 Oct 2015 16:34:45 +0200
From: Sander Smeenk <ssmeenk@freshdot.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: CAP(abilities) and NFS mounted storage
Message-ID: <20151013143445.GE10632@dot.dmz.freshdot.net>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
 <CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Trond Myklebust (trond.myklebust@primarydata.com):

> > I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
> > not enough. I'd very much like to hear if it is possible for this to
> > work on NFS like it does on local storage.
> This will not work on NFS. The server, which enforces permissions, has
> no way to know what capabilities your process has on the client.

Thanks. I feared this answer. But i understand that the NFS-server cant
know if the process on the NFS-client has CAP_DAC_READ_SEARCH
capabilities set.

Would setfsuid() help anything in this case? Or is it just a big no-go?

-Sndr.
-- 
| Daylight savings time - why are they saving it and where do they keep it?
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
