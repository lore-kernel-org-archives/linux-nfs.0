Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:34706 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752020Ab2DTTpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 15:45:09 -0400
Date: Fri, 20 Apr 2012 15:45:04 -0400
From: Jim Rees <rees@umich.edu>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Message-ID: <20120420194504.GA10259@umich.edu>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334949705-33393-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Weston Andros Adamson wrote:

  nfs4_path() was parsing the path component by splitting on the first colon.
  This is wrong when an IPv6 address is used to mount a server.
  
  For example, having mounted 'fc00::10:/export', nfs4_path() returned
  ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) to fail
  in nfs4_validate_fspath().
  
  Parsing the path component by using the *last* colon works with
  IPv6 as well as IPv4 addrs.

What if your mount is:

server.edu:/export/:I-like-colons:

It seems to me something has to give.  Either we require v6 addresses be
enclosed in [], export dirs start with "/", or exports have no ":".
