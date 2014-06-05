Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32855 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbaFECbw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 22:31:52 -0400
Date: Wed, 4 Jun 2014 22:31:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs 05/17] move .x files to subdir 'xdrdef'
Message-ID: <20140605023150.GC12044@fieldses.org>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
 <1401915726-29092-6-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401915726-29092-6-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2014 at 05:01:53PM -0400, Weston Andros Adamson wrote:
>  nfs4.1/nfs4.x                               | 3290 ---------------------------
...
>  nfs4.1/xdrdef/nfs4.x                        | 3290 +++++++++++++++++++++++++++

git should be able to show that as a rename instead of a huge add/delete
pair.  Maybe git-format-patch needs the -M option or something?

--b.
