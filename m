Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:49723 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab2BWNCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 08:02:50 -0500
Date: Thu, 23 Feb 2012 08:02:45 -0500
From: Jim Rees <rees@umich.edu>
To: Gregor Gruener <ggruner@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2.6.32-131.6.1.el6.x86_64] idmapd.c: deactivate the ASCII
 characters check
Message-ID: <20120223130245.GA4776@umich.edu>
References: <4F4603EC.9030404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <4F4603EC.9030404@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gregor Gruener wrote:

  Customers are using Unicode characters umlauts (ö,ä,ü) in group names and this
  creates problems with NFS ID Mapping. Groups with umlauts will be redirected to
  the group NFS "nobody".
  This patch deactivate the ASCII characters check. It's maybe more like a temporary fix and I think it would be nicer to
  adjust the check to support Unicode characters instead to deactivate the
  check.

Maybe the name of the routine should also be changed to something other than
validateascii().  But I'm curious why that check was put in there.

I found this in rfc5661 section 22.1, which seems to be a bug in the spec:

   1.  A US-ASCII string name that is the actual name of the attribute.
       This name must be unique.  This string name can be 1 to 128 UTF-8
       characters long.
