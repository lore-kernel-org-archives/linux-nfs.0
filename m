Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54115 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1CUDJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Mar 2011 23:09:31 -0400
Date: Mon, 21 Mar 2011 14:09:23 +1100
From: NeilBrown <neilb@suse.de>
To: Dennis Jacobfeuerborn <d.jacobfeuerborn@conversis.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: bind mounts, crossmnt and multi client nfsv3
Message-ID: <20110321140923.5a618d89@notabene.brown>
In-Reply-To: <4D86B6F2.1070004@conversis.de>
References: <4D86B6F2.1070004@conversis.de>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 21 Mar 2011 03:24:50 +0100 Dennis Jacobfeuerborn
<d.jacobfeuerborn@conversis.de> wrote:

> Hi,
> I have a storage system that is exporting many directories to multiple 
> clients resulting in a lot of mountpoints (156) on each client. What I'm 
> trying to do is to create a single directory on the server and then use 
> mount --bind to mount all the different directories (which are stored on 
> different LVM volumes) into this single export directory and finally export 
> this directory to the clients.
> Now the exports man-page mentions the crossmnt option but it also mentions 
> that it cannot be used if I want to export the directory to multiple 
> clients. Is there another way to accomplish something like this?
>

Just export the top directory with 'crossmnt' - it should work fine.

The 'multiple clients' thing only affects 'nohide' and I think it only
affected it back in 2.4 days.
Lots changed with 2.6, but maybe not enough of the man page changed :-(

So try with 'crossmnt' and if it doesn't work, then come back with details.

NeilBrown

