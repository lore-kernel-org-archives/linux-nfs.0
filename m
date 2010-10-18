Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:35829 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400Ab0JRQJy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 12:09:54 -0400
Date: Mon, 18 Oct 2010 12:09:53 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pnfs-nfs-utils compile errors
Message-ID: <20101018160953.GA19529@merit.edu>
References: <AANLkTin3xF4+QbG8G2pgiUxv9mUMmFOnQOUD2C1ocVrA@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTin3xF4+QbG8G2pgiUxv9mUMmFOnQOUD2C1ocVrA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peng Tao wrote:

  I fail to compile with pnfs-nfs-utils master branch (commit
  48a8d6b13b2f0b720267b1af104addb7426e7cc9). It fails in blkmapd
  directory. Are the files cfg.c and cfg.h missing or deleted?

Yes, they were removed in commit fb9c48c5e1ce2023d3dc2e279537e158130a6ba0,
"blkmapd: get rid of config file and instead examine all block devices."
Maybe you need to do a autogen.sh or make distclean?
