Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:33701 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab0I3UW5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 16:22:57 -0400
Date: Thu, 30 Sep 2010 16:22:56 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs:  compile error in blocklayout code
Message-ID: <20100930202256.GA6462@merit.edu>
References: <4CA4ED68.3090806@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA4ED68.3090806@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  I needed to make the following change to get the
  block layout code to compile in a Fedora build 
  environment.

  -#include <../pnfs.h>
  +#include "../pnfs.h"

Not a comment on your fix, which looks correct, but there is a bit of
disturbing asymmetry here.  The file layout source files are named
nfs4filelayout*.[ch] and live in fs/nfs, but object and block layout are
named {object,block}layout*.[ch] and live in fs/nfs/*layout.
