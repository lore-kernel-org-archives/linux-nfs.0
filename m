Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.g1.pair.com ([66.39.3.162]:62780 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366AbaICNbX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 09:31:23 -0400
Date: Wed, 3 Sep 2014 15:31:24 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Accessing alternate data streams on NFSv4 server?
Message-ID: <20140903153124.18da9ad3@harpe.intellique.com>
In-Reply-To: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
References: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Wed, 3 Sep 2014 11:14:13 +0200
Cedric Blancher <cedric.blancher@gmail.com> écrivait:

> is there any utility which can be used to access alternate data
> streams (which can be accessed on Solaris via O_XATTR or newer
> bash/ksh versions via cd -@) on Linux?
> 

Extended attributes work fine on various Linux filesystems, and are
accessible through samba and NFS. However AFAIK only Solaris supports
full alternate data streams (bigger than 64K). BTW from a quick google
search it looks like you're about the only one in the world using this
very idiosyncratic feature ;) -- all other references to this problem
comes from you on FreeBSD lists :)

I guess it would be too much work to implement in either Linux or
FreeBSD as the VFS doesn't really provide anything to support that
properly.

So your best bet is to check with preferably SmartOS, or
eventually OmniOS/IllumOS (all of them OpenSolaris forks);

or to write a samba module as a horrid hack to emulate the API and
store the big XATTRs into alternate files /alla/ .AppleDouble
(.SolarisDouble anyone?). I know, I know; it's ugly as sin but it seems
actually quite doable, if not actually easy.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
