Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51375 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758207Ab0HDDpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 23:45:34 -0400
Date: Wed, 4 Aug 2010 13:45:27 +1000
From: Neil Brown <neilb@suse.de>
To: Jason Keltz <jas@cse.yorku.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: exporting to a list of IPs
Message-ID: <20100804134527.146397ff@notabene>
In-Reply-To: <4C583B63.4050903@cse.yorku.ca>
References: <4C583B63.4050903@cse.yorku.ca>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 03 Aug 2010 11:53:07 -0400
Jason Keltz <jas@cse.yorku.ca> wrote:

> Hi.
> 
> Why is it that you cannot NFS export to a list of IPs and have exportfs 
> leave the list of IPs in etab without converting over to FQDN?

My memory is that if you only list IP addresses in /etc/exports then it will
do just want you want.  But if you list any host names or net groups then it
has to do a DNS lookup on everything to see if either of those matches.

> 
> In Changelog:
> 
> 2001-09-20 NeilBrown <neilb@cse.unsw.edu.au>
>              Anne Milicia <milicia@missioncriticallinux.com>
> 
>          * support/export/client.c (client_lookup) call gethostbyadd
>          to make sure that we have a canonical hostname, even for
>          dotted-quads

I think this patch only related to netgroup lookups.

> 
> Why does mountd need to repeat the gethostbyname() lookup on every host 
> even though exportfs already converted over to using hostname?

exportfs doesn't convert over host hostnames.  It essentially
copies /etc/exports to /var/lib/nfs/etab with minor formatting changes.

What do you actually put in /etc/exports, what do you find
in /var/lib/nfs/etab, and what exactly is the problem?

NeilBrown


> 
> Thanks,
> 
> Jason.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

