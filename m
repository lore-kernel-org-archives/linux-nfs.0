Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:46532 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932214Ab2B2Viv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Feb 2012 16:38:51 -0500
Date: Wed, 29 Feb 2012 16:38:38 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Gregor Gruener <ggruner@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2.6.32-131.6.1.el6.x86_64] idmapd.c: deactivate the ASCII
 characters check
Message-ID: <20120229213838.GA1560@umich.edu>
References: <4F4603EC.9030404@redhat.com>
 <4F4E8F3A.8070708@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <4F4E8F3A.8070708@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  On 02/23/2012 04:16 AM, Gregor Gruener wrote:
  > Customers are using Unicode characters umlauts (ö,ä,ü) in group names and this
  > creates problems with NFS ID Mapping. Groups with umlauts will be redirected to
  > the group NFS "nobody".
  > This patch deactivate the ASCII characters check. It's maybe more like a temporary fix and I think it would be nicer to
  > adjust the check to support Unicode characters instead to deactivate the check.
  > Signed-off-by: Gregor Gruener<ggruner@redhat.com>
  ...
  Committed... 

I still think the name should be changed.  The only thing validateascii() is
doing now is verifying that the string is null terminated.
