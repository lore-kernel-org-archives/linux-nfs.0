Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36858 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab2BPA2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 19:28:20 -0500
Message-ID: <4F3C4D91.20300@panasas.com>
Date: Wed, 15 Feb 2012 16:28:01 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: pynfs: cleanup and turn off some tests by default
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/15/2012 02:45 PM, J. Bruce Fields wrote:
> I've committed the following to my pynfs repo.
> 
> Fix a couple minor problems found while working on a bug, then turn off
> utf8 and pnfs tests by default (both can still be requested by adding
> "utf8" or "pnfs", respectively, on the commandline), and remove one
> incorrect test.
> 
> I'd like to get to the point where the pynfs tests all pass against a
> reasonable server.  That means fixing the server where necessary, of
> course, but also not complaining about unimplemented optional features
> or about stuff we don't plan to fix.
> 

Can't we "auto detect" the pnfs option. Request a pnfs access if failed
proceed to the next set of tests, if successful continue to test "pnfs"

> --b.
> 

Thanks
Boaz
