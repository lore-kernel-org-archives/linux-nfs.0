Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34420 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730017AbeISCNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Sep 2018 22:13:10 -0400
Date: Tue, 18 Sep 2018 16:38:52 -0400
To: Ryan Richter <ryan@tau.solarneutrino.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mkdir disregards umask
Message-ID: <20180918203852.GG1218@fieldses.org>
References: <20180912181747.GQ31400@tau.solarneutrino.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180912181747.GQ31400@tau.solarneutrino.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 12, 2018 at 02:17:47PM -0400, Ryan Richter wrote:
> All directories created over nfs have 777 permissions.
> 
> # umask
> 022
> # mkdir aaaa
> # ls -ld aaaa
> drwxrwxrwx 2 root root 2 Sep 12 13:45 aaaa
> # rmdir aaaa
> # mount|grep /mnt
> mazuelo:/home/sbio/ryan on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=132.204.84.95,mountvers=3,mountport=38634,mountproto=udp,local_lock=none,addr=132.204.84.95)
> 
> The same happens for regular users.
> 
> This is a very serious bug.  The server is runnig the debian stretch 4.9
> kernel, and the client is running a vanilla 4.4.155.  Is there anything
> in the configuration causing this, or is it a kernel bug?

Beats me, I can't reproduce that on a recent kernel.

Does it look the same if you run the "ls -l" on the server itself?

--b.
