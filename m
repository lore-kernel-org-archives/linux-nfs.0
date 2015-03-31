Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49692 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593AbbCaVxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 17:53:00 -0400
Date: Tue, 31 Mar 2015 17:52:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] 4.1 server tests: new helper get_blocksize for pnfs
 client
Message-ID: <20150331215258.GT6901@fieldses.org>
References: <551918AB.5030004@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <551918AB.5030004@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, I've applied all 3.

Also, I've pushed out a little clean up and some very minimal 4.2
support.

--b.

J. Bruce Fields (9):
      4.0 server tests: skip test expecting STALE error
      4.0 server tests: note acl tests assume auth_unix
      4.1 server tests: remove out-of-date open tests
      4.1: remove dead code
      4.1 server tests: Allow tests to specify minor version range
      Update to draft 4.2 xdr
      stop setup.py asking whether to setup all subdirectories
      4.1 server tests: add basic ALLOCATE test
      4.0 server tests: remove unused server workarounds

Kinglong Mee (3):
      4.1 server tests: fix typos of FATTR4_FS_LAYOUT_TYPES
      4.1 server tests: new helper new_pnfs_client_session for pnfs client
      4.1 server tests: new helper get_blocksize for pnfs client

