From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: spkm3 removal
Date: Fri, 01 Oct 2010 16:11:31 -0400
Message-ID: <1285963891.4391.0.camel@heimdal.trondhjem.org>
References: <20101001195150.GB1472@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33732 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab0JAULs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 16:11:48 -0400
In-Reply-To: <20101001195150.GB1472@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-10-01 at 15:51 -0400, J. Bruce Fields wrote:
> Shall we go ahead and remove this?
> 
> Somebody stumbled across a security problem in the spkm3 code
> recently--unexploitable, as far as I can tell, since you'd need an spkm3
> context first, and those are hard to come by....  But I feel a little
> bad leaving this code around for innocent bystanders to waste their time
> auditing.

Agreed. Let's get rid of it.

Cheers
  Trond
