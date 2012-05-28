Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54054 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab2E1QgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 12:36:20 -0400
Message-ID: <4FC3A974.60107@panasas.com>
Date: Mon, 28 May 2012 19:36:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com> <4FC3A235.8090908@tonian.com>
In-Reply-To: <4FC3A235.8090908@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2012 07:05 PM, Benny Halevy wrote:

> Yup, see patchset in reply.
> 


That I wish you wouldn't do. I have a patchset pending that makes
major changes to all this and totally conflicts with your code.

You can carry this for a while but I might revert your core
code in my new patchset.

Sigh, more work for me.

Boaz
