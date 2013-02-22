Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:63973 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757099Ab3BVNLN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 08:11:13 -0500
Date: Fri, 22 Feb 2013 08:11:01 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.2: Added NFS v4.2 support to the NFS client
Message-ID: <20130222131101.GA12862@umich.edu>
References: <1361522832-11177-1-git-send-email-steved@redhat.com>
 <1361522832-11177-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1361522832-11177-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  +config NFS_V4_2
  +	bool "NFS client support for NFSv4.2"
  +	depends on NFS_V4_1
  +	select NFS_V4_SECURITY_LABEL
  +	help
  +	  This option enables support for minor version 1 of the NFSv4 protocol
  +	  in the kernel's NFS client.
  +
  +	  If unsure, say N.
  +

Shouldn't that be "enables support for minor version 2..."?
