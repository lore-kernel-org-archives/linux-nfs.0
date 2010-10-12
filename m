Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:59809 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932068Ab0JLLua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 07:50:30 -0400
Date: Tue, 12 Oct 2010 07:50:26 -0400
From: Jim Rees <rees@umich.edu>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: POSIX's "tables of the law"
Message-ID: <20101012115026.GB2577@merit.edu>
References: <4CB443F6.5060106@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB443F6.5060106@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

DENIEL Philippe wrote:

  on many aspects, knowing the POSIX standard and behavior is quite
  important when working on implementing something like NFSv4. There a
  problem occur : if I need information on NFS (whatever version) or
  any "related" protocol (RPCSEC_GSS, ONCRPC, ...) I can easily find a
  document that is the absolute reference to use. But what about POSIX
  ? I must have missed something but I never see such a reference. Do
  you have book references to provide me with about this subject ?

The posix spec situation is confused because there are many different specs
published at different times, and the ones that are most important (like
acls) were never ratified as far as I know, so are still in draft form.
Originally they were ISO specs, which cost big money, which is why you won't
find them on the web.  More recently I think the Open Group has been working
on them, maybe you'll find copies there: www.opengroup.org
