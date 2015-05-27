Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbbE0SBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 14:01:34 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1Xrw029604
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:34 -0400
Received: from bcodding-csb.redhat.com (vpn-55-212.rdu2.redhat.com [10.10.55.212])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1XLY015070
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:33 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 0/3] MITM tool for NFS traffic on linux
Date: Wed, 27 May 2015 14:01:29 -0400
Message-Id: <cover.1432749206.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

What follows is a small tool I think may be convenient to test and reproduce
certain types of bugs that are difficult to create from above the
filesystem, but are clearly problematic and have well-defined network
triggers.  Anna's recent BAD_STATEID on WRITES with delegation is a good
example of that.  This tool uses netfilters NFQUEUE target to allow a linux
host to modify the NFS network traffic between existing clients and servers.
In that sense, it is very similar to nfs-proxy, however I find it to be much
more convenient to use, as it can be quickly inserted and removed from an
existing network conection.

Benjamin Coddington (3):
  Fix default arg order error on swig > 1.x
  Add a tool for modification of NFS network traffic: itm
  itm: add a handler that truncates READDIR response page data

 gssapi/gssapi.i                       |    2 +
 itm/README                            |   26 ++++
 itm/handlers.py                       |    9 ++
 itm/handlers/default.py               |   19 +++
 itm/handlers/example.py               |   14 ++
 itm/handlers/readdir_reply_nopages.py |   86 ++++++++++++
 itm/itm.py                            |  230 +++++++++++++++++++++++++++++++++
 itm/run_itm.sh                        |   41 ++++++
 itm/use_local.py                      |   14 ++
 9 files changed, 441 insertions(+), 0 deletions(-)
 create mode 100644 itm/README
 create mode 100644 itm/__init__.py
 create mode 100644 itm/handlers.py
 create mode 100644 itm/handlers/__init__.py
 create mode 100644 itm/handlers/default.py
 create mode 100644 itm/handlers/example.py
 create mode 100644 itm/handlers/readdir_reply_nopages.py
 create mode 100755 itm/itm.py
 create mode 100755 itm/run_itm.sh
 create mode 100644 itm/use_local.py

