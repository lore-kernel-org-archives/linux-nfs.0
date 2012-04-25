Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50888 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759345Ab2DYWWd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 18:22:33 -0400
Date: Wed, 25 Apr 2012 18:22:31 -0400
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: LOOKUP Reply Error:NFS3ERR_NO_ENT
Message-ID: <20120425222231.GE3251@fieldses.org>
References: <4F986927.9020102@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F986927.9020102@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 25, 2012 at 11:14:15PM +0200, steve wrote:
> Sorry:
> also just seen this:
> 
> CREATE Reply Error:NFS3ERR_ACCES

What principal are you authenticated as?

--b.
