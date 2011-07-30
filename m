Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63079 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab1G3Sld convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 14:41:33 -0400
Subject: Re: [PATCH v6 00/26] add block layout driver to pnfs client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Sat, 30 Jul 2011 14:41:32 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312051292.26265.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2011-07-30 at 13:08 -0400, Jim Rees wrote: 
> This patch set adds a block layout driver to the pNFS client.  It passes
> Connectathon tests and is bisectable.  It requires an updated version of
> nfs-utils, and patches for that have been sent separately to the nfs-utils
> maintainer.

There is one more thing I need in order to apply these: your signoff on
all these patches.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

