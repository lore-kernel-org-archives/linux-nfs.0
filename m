Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55319 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab1EJA7d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2011 20:59:33 -0400
Date: Mon, 9 May 2011 20:59:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSD Secinfo no name
Message-ID: <20110510005931.GD3600@fieldses.org>
References: <4DC43CE7.7070705@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DC43CE7.7070705@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 06, 2011 at 02:24:39PM -0400, Bryan Schumaker wrote:
> Hi Bruce,
> 
> On the call yesterday you asked me to double check that secinfo no name still works in NFSD.  It does still work for me.

My real question was whether the bug you reported here:

	http://marc.info/?l=linux-nfs&m=130192462122087&w=2

appears to have been fixed (in my for-2.6.40 branch) to your
satisfaction?

--b.
