Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41537 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2EXNub (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2012 09:50:31 -0400
Message-ID: <4FBE3C9A.8090907@panasas.com>
Date: Thu, 24 May 2012 16:50:18 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com>
In-Reply-To: <4FBE3C4D.7050507@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/2012 04:49 PM, Boaz Harrosh wrote:

> and it's call site. It is called on last call and all is working well (except some locking


I meant last close not last call

Boaz
