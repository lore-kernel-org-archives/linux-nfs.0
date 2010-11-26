Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab0KZSF3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Nov 2010 13:05:29 -0500
Subject: Re: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache
 array" is bad
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, Bryan Schumaker <bjschuma@netapp.com>,
        rees@umich.edu, sim@hostway.ca
In-Reply-To: <Pine.LNX.4.64.1011261255260.16655@axis700.grange>
References: <Pine.LNX.4.64.1011261255260.16655@axis700.grange>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Nov 2010 13:05:26 -0500
Message-ID: <1290794726.4905.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Fri, 2010-11-26 at 13:05 +0100, Guennadi Liakhovetski wrote:
> Hi all
> 
> I've bisected the problem, reported several times before:
> 
> http://www.spinics.net/lists/linux-nfs/msg17208.html
> http://www.spinics.net/lists/linux-nfs/msg17298.html
> 
> (authors cc'ed) and also causing reproducibly problems on my sh7724 SuperH 
> and sh7372 ARM Debian systems. Commit
> 
> commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
> Author: Bryan Schumaker <bjschuma@netapp.com>
> Date:   Fri Sep 24 14:48:42 2010 -0400
> 
>     NFS: add readdir cache array
> 
> can be verified to be the culprit. Would be nice, if the other two 
> reporters could also verify this commit. Or is there already a fix 
> available?
> 

That patch removes readdirplus, and cannot therefore be responsible for
the fileid changed error that is reported in the emails below (which
does not occur when mounting with -onordirplus). It introduces a bunch
of other bugs (most which have been fixed), but not that one.

I've asked Simon for info about which NFS versions he is seeing this
with. He has not replied so far, but if you are seeing the same bug,
then I'd appreciate the same info.
Does the fileid bug occur with NFSv3 and NFSv4 or is it limited to one
or the other?

Cheers
  Trond


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

