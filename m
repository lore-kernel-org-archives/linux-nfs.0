From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: pseudo root status?
Date: Fri, 19 Feb 2010 23:45:08 -0500
Message-ID: <20100220044508.GA3689@fieldses.org>
References: <20100219190049.GA32080@esri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ray Van Dolson <rvandolson-v48TKWNzwFw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50148 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755998Ab0BTEoV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2010 23:44:21 -0500
In-Reply-To: <20100219190049.GA32080-v48TKWNzwFw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 19, 2010 at 11:00:49AM -0800, Ray Van Dolson wrote:
> What is the status of the dynamic pseudo root support in nfs-utils?  I
> see in commit b25694320f2bdd79de82f2003209b8229eafff36 mention of a way
> to define an export with a pseudo root, but I cloned Steve's latest git
> tree of nfs-utils and am not seeing much about pseudo root support at
> all.
> 
> The 1.2.2 announcement message seems to include a blurb about it --
> does this version have what I need?

With a recent kernel and nfs-utils, if you just omit "fsid=0" from your
export file then NFSv4 clients should see the same paths as v2/v3
clients.

--b.
