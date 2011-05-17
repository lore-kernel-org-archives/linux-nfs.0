Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33873 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932367Ab1EQWBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 18:01:13 -0400
Date: Wed, 18 May 2011 08:01:06 +1000
From: NeilBrown <neilb@suse.de>
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for
 different client formats?
Message-ID: <20110518080106.1159c5b8@notabene.brown>
In-Reply-To: <4DD2A084.1040905@moving-picture.com>
References: <4DD2A084.1040905@moving-picture.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 17 May 2011 17:21:24 +0100 James Pearson <james-p@moving-picture.com>
wrote:

> I'm using CentOS 5.x (nfs-utils based on v1.0.9) - and have been using 
> the following in /etc/exports:
> 
> /export *(rw,async) @backup(rw,no_root_squash,async)
> 
> which works fine - hosts in the backup NIS netgroup mount the file 
> system with no_root_squash and other clients with root_squash
> 
> However, I now want to restrict the export to all clients in a single 
> subnet - so I now have /etc/exports as:
> 
> /export 172.16.0.0/20(rw,async) @backup(rw,no_root_squash,async)
> 
> Unfortunately, hosts in the backup NIS netgroup (which are also in the 
> 172.16.0.0/20 subnet) no longer mount with no_root_squash
> 
> It appears that the subnet export takes precedence over the netgroup 
> export (it doesn't matter in what order the subnets/netgroups exports 
> are listed in /etc/exports) - so the netgroup client options are ignored 
> as a match has already been found in the subnet export.
> 
> Is there any way to control the order in which clients are checked for 
> export options?
> 
> i.e. I would like netgroups to take precedence over subnets

Unfortunately you cannot do that.

The place in the code where this is determined is towards the end of
'lookup_export' in utils/mountd/cache.c

Were I to try to 'fix' this I would probably define a new field in 'struct
exportent' which holds a 'priority'.

Then allow a setting like "priority=4" in /etc/exports

Then change the code in lookup_export to choose the one with the higher
priority, rather than the 'first' one.

NeilBrown
