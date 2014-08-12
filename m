Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:38012 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbaHLHAM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 03:00:12 -0400
Date: Tue, 12 Aug 2014 08:59:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Nick Krause <xerofoify@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>,
        Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [nfs] BUG: sleeping function called from invalid context at
 include/linux/wait.h:976
Message-ID: <20140812065958.GL9918@twins.programming.kicks-ass.net>
References: <20140805140307.GB5593@localhost>
 <DBF9CA04-ACDF-47AC-9FA6-57DD202D2AC1@primarydata.com>
 <CAPDOMVibdcRRdqGRsK4kq+cdh3yBjBU4XB7JjTfyOMFk+jYyvA@mail.gmail.com>
 <7EA40233-6820-4F0E-A2B7-687DC01BDD78@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mCRau3CSwZDVtMjk"
In-Reply-To: <7EA40233-6820-4F0E-A2B7-687DC01BDD78@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--mCRau3CSwZDVtMjk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 11, 2014 at 10:52:38PM -0400, Weston Andros Adamson wrote:
> Weston Andros Adamson (5):
>  nfs: change nfs_page_group_lock argument
>  nfs: fix nonblocking calls to nfs_page_group_lock
>  nfs: use blocking page_group_lock in add_request
>  nfs: fix error handling in lock_and_join_requests
>  nfs: don't sleep with inode lock in lock_and_join_requests

Thanks for taking care of that!

--mCRau3CSwZDVtMjk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT6btuAAoJEHZH4aRLwOS6VXIP/AqO8xRL7NO7NVavywjpPV4Q
uM0ummIaAtYI/iUK+pZ8DPnKCC6ZgIWqCqlaHeld4ABMCD9hKRtD42CFiz901nxp
lckzLMsRyAPeYFfRovLwjRxrwBFwKwupdCHBK0+Jr6ifwvromya5bx19AgO1++0X
Nx2L7qH8KFN6ZNC0uxdvLrbwOdiWdQB2ozCv/7EFtE+OBJXLzfAFluJXpDtB0cH7
OAsrguSl++onebXfFe5zDpFjzShp5hPr5JdIPT3RKQ8SkOT3ESqPUieYeaEpnSwJ
soTUrpLGCewj4eYjPQ5I3TNGdpYS885FOZsBj5+oIH2U/ScuvnT2+qzqxvbwOefs
fp1/giMWHTme0RDLCWQcOPbXvuQEbhCF5SgSElP5NJc0kYGpsY1zEhx4LFjZ4H4U
SQLpUYuDTBayQ5LzUuz352+nnvJlwScbuuKeGIjEd78K8lDP94JD1UqAJqap4kqO
bH0Uy6HQ3vcU0I5wkGX1hjgi0dI4hG7E/4NJmvOAIlN8oLSyFj20jdQSQBdZsNZ8
GMLFPRHFJISrAKn9MmLiSZG2oujhSowmCWWjyJNm/bAa7/9lfmU4YEkgrgUm7sPf
DCZBkDLqP3VAN76vPHiJ+xXJxOmSOs6eyCTzQEk4fii8IG0foSNcVvOwsBii9TOr
Ru/r05AOPa6FODQU+3xL
=oKFG
-----END PGP SIGNATURE-----

--mCRau3CSwZDVtMjk--
