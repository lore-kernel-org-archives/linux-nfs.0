Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48292 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690Ab2CBSD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 13:03:57 -0500
Date: Fri, 2 Mar 2012 13:03:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120302180355.GA25925@fieldses.org>
References: <20120228200524.GE2723@fieldses.org>
 <4F4D61B6.5090304@steve-ss.com>
 <20120229124401.GA9160@fieldses.org>
 <4F4E306C.6030400@steve-ss.com>
 <20120229140903.GA3007@fieldses.org>
 <4F4E3599.2050209@steve-ss.com>
 <20120229143236.GB3007@fieldses.org>
 <4F4E38E7.6060308@steve-ss.com>
 <20120301205639.GC17433@fieldses.org>
 <4F4FF40C.4050905@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4FF40C.4050905@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 01, 2012 at 11:11:24PM +0100, steve wrote:
> 1. Do we need to remove /etc/idmapd.conf for nfs3?

No.

> 2. Could I take this opportunity to ask as a feature request that
> nfs4_setfacl be able to offer group rw from a 0022 umask?

I agree that this needs to be fixed, but personally it's not likely to
make it to the top of my todo list very soon.

--b.
