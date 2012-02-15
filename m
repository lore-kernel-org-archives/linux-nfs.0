Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail131.messagelabs.com ([216.82.242.99]:38443 "EHLO
	mail131.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab2BOONF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 09:13:05 -0500
Message-ID: <4F3BBCF8.8070402@nexenta.com>
Date: Wed, 15 Feb 2012 18:11:04 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>  <1329259606.11759.15.camel@lade.trondhjem.org>  <4F3AFD84.3020709@nexenta.com>  <1329266587.28837.4.camel@lade.trondhjem.org>  <20120215005315.GA9018@fieldses.org>  <1329270628.28837.15.camel@lade.trondhjem.org> <1329273001.28837.19.camel@lade.trondhjem.org>
In-Reply-To: <1329273001.28837.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good.

However here MUST be checking on big value of ses->fc_attrs.max_reqs and 
  ses->bc_attrs.max_reqs. I'll send it soon.



On 02/15/2012 06:30 AM, Myklebust, Trond wrote:
>
> Here's a version 2 that does a few more cleanups by merging the
> nfs4_init_slot_table() and nfs4_reset_slot_table() into a single
> function.
>
