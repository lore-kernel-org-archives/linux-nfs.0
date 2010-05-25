Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38999 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754211Ab0EYLZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 07:25:24 -0400
Message-ID: <4BFBB3A1.8020300@panasas.com>
Date: Tue, 25 May 2010 14:25:21 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: redshield88888 <redshield88888@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Can the pNFS be able to construct high-available about the data
 ?
References: <loom.20100525T092804-609@post.gmane.org>
In-Reply-To: <loom.20100525T092804-609@post.gmane.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/25/2010 10:41 AM, redshield88888 wrote:
> Hi
> 
> I wonder that about the pNFS's high availability.
> The pNFS will stripe a file on each DSs, so this file will be currupted when one
> DS has crushed, will not ?
> 

pNFS over objects can do that, and striping over mirrors, and more.

You need to use: pnfs-client with objlayoutdriver on client, exofs on MDS, and osd-targets
on disk-servers.

Cheers Boaz
