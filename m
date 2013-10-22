Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:59965 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab3JVLjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 07:39:46 -0400
Date: Tue, 22 Oct 2013 07:39:40 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] mountd: Deprecate the ability to disable TCP
 listeners.
Message-ID: <20131022113940.GA15951@umich.edu>
References: <1382429966-14531-1-git-send-email-steved@redhat.com>
 <1382429966-14531-3-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382429966-14531-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  -"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
  +"	[-N version|--no-nfs-version version] [-n|--no-tcp(deprecate)]\n"

I would take this out.
