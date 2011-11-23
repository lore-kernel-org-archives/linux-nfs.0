Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:59240 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754077Ab1KWClm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 21:41:42 -0500
Date: Tue, 22 Nov 2011 21:41:36 -0500
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: bjschuma@netapp.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
Message-ID: <20111123024136.GA1823@umich.edu>
References: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
 <4ECC5823.5060509@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ECC5823.5060509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  I set my git tree to do the -M by default it's a git config something
  something check it out.

Me too.  Not sure, but I think it's this one:
git config --global diff.renames copy
