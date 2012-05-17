Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51364 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510Ab2EQMIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 08:08:09 -0400
Message-ID: <4FB4EA0E.6000101@panasas.com>
Date: Thu, 17 May 2012 15:07:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Mike Frysinger <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] osd_login: fix DESTDIR install
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org> <20120517115330.GA3733@umich.edu>
In-Reply-To: <20120517115330.GA3733@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2012 02:53 PM, Jim Rees wrote:

> 
> Also it might be worth mentioning in the comment why we have this
> restriction.


This is because this script is called by Kernel and is
expected to be at /sbin/osd_login

Though there is a module param to change that.

Thanks, for the fix guys
Boaz


