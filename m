Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:56134 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588Ab1G3DX5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 23:23:57 -0400
Date: Fri, 29 Jul 2011 23:23:54 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v5 20/27] pnfsblock: add extent manipulation functions
Message-ID: <20110730032354.GA25188@merit.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
 <1311954892-22038-21-git-send-email-rees@umich.edu>
 <1311987784.16078.12.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311987784.16078.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  On Fri, 2011-07-29 at 11:54 -0400, Jim Rees wrote:
  
  > +
  > +/* We are relying on page lock to serialize this */
  > +int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect)
  
  This either needs a prefix, or it should be declared 'static'

Clearly I need to go through the source and systematically catch all of
these.  Anyone have a good tool for doing so?  Otherwise I'll give nm a try.
