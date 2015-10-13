Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:48882 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310AbbJMRwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 13:52:33 -0400
Date: Tue, 13 Oct 2015 19:52:33 +0200
From: Sander Smeenk <ssmeenk@freshdot.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: CAP(abilities) and NFS mounted storage
Message-ID: <20151013175233.GF10632@dot.dmz.freshdot.net>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
 <CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
 <20151013143445.GE10632@dot.dmz.freshdot.net>
 <CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Olga Kornievskaia (aglo@umich.edu):

> >> > I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
> >> > not enough. I'd very much like to hear if it is possible for this to
> >> > work on NFS like it does on local storage.
> >> This will not work on NFS. The server, which enforces permissions, has
> >> no way to know what capabilities your process has on the client.
> > Thanks. I feared this answer. But i understand that the NFS-server cant
> > know if the process on the NFS-client has CAP_DAC_READ_SEARCH
> > capabilities set.
> > Would setfsuid() help anything in this case? Or is it just a big no-go?
> 
> Are you looking for something like labeled NFS that supports
> capabilities? I think Redhat7 has SElinux labeled NFS support.

SELinux might be a bit too much for our situation. ;)

I'm looking for an answer to who exactly controls filesystem access
permission checks when dealing with files on an NFS mount, and perhaps
an answer to why these permission checks seem to differ for files on NFS
mounts and files on locally attached storage w/ strict capabilities set.

Regards,
-Sndr.
-- 
| Have you ever imagined a world with no hypothetical situations?
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
