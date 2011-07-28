Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10832 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754748Ab1G1Upc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:45:32 -0400
Date: Thu, 28 Jul 2011 16:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH 5/6] Merge top-level READMEs
Message-ID: <20110728204529.GP10682@pad.fieldses.org>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
 <1311883384-20260-6-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311883384-20260-6-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 04:03:03PM -0400, J. Bruce Fields wrote:
> +You can prepare both for use with a single
> +	./setup.py build_ext --inplace
> +which will create auto-generated files and compile any shared libraries
> +in place.

This, by the way, is a bald-faced lie.

Or anyway, at least I'm having trouble getting the tests to run unless I
do a "setup.py build".

But I thought I'd just leave it as is and get you to explain what's
actually supposed to work....

--b.
