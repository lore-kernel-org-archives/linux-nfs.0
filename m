Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12086 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754246Ab0DNRys convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 13:54:48 -0400
Subject: Re: [PATCH 00/22] Add support for more RPCSEC_GSS/krb5 enctypes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100414174703.GA26724@fieldses.org>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20100414174703.GA26724@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Apr 2010 13:54:47 -0400
Message-ID: <1271267687.22566.16.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-04-14 at 13:47 -0400, J. Bruce Fields wrote: 
> On Wed, Apr 14, 2010 at 01:36:36PM -0400, Trond Myklebust wrote:
> > The following patches have been queued up in the nfs-for-2.6.35 branch
> > on git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> 
> How are you testing this?  (Is there code for the userspace side?)

SteveD has promised to release the nfs-utils patches soon.

He is also the one responsible for testing these patches. All I did was
clean them up, and change the enctype advertising so that we pass that
information directly in the upcall instead of adding another pseudofile
in rpc_pipefs.

Cheers
  Trond
