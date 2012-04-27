Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:40375 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756613Ab2D0Lmf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 07:42:35 -0400
Date: Fri, 27 Apr 2012 07:42:25 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Weston Andros Adamson <dros@netapp.com>, SteveD@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add IPv6 addr escaping to fs_location hosts
Message-ID: <20120427114225.GA32394@umich.edu>
References: <1335279577-46822-1-git-send-email-dros@netapp.com>
 <20120427112529.GA14973@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120427112529.GA14973@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

  > +			for (; *end && (*end != esc_exit); end++);
  
  I kinda like keeping the semicolon on its own line here.  Tastes may
  differ.

Tastes may differ, but the official kernel style requires putting the
semicolon on a separate line.
