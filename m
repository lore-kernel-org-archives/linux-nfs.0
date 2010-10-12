Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:42822 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932193Ab0JLLng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 07:43:36 -0400
Date: Tue, 12 Oct 2010 07:43:34 -0400
From: Jim Rees <rees@umich.edu>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: RPM packaging for libnfsidmap ?
Message-ID: <20101012114334.GA2577@merit.edu>
References: <4CB4432B.7020709@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB4432B.7020709@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

DENIEL Philippe wrote:

  I have searched on Google, and I found no distribution of libnfsidmap as
  a rpm package (but I could easily find the tarball on CITI's website).
  On my site, I need such a rpm (we have a massive cluster with yum
  repository + configuration files managed by Puppet) so I will do it if
  none is available.

On fedora it's part of nfs-utils-lib-devel.  I don't know about rhel.
