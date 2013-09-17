Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:60455 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527Ab3IQMVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Sep 2013 08:21:42 -0400
Date: Tue, 17 Sep 2013 08:21:35 -0400
From: Jim Rees <rees@umich.edu>
To: Bohuslav Kabrda <bkabrda@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Make mountstats and nfs-iostat Python 3 compatible
Message-ID: <20130917122135.GC11758@umich.edu>
References: <1379409678-15730-1-git-send-email-bkabrda@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1379409678-15730-1-git-send-email-bkabrda@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bohuslav Kabrda wrote:

  This will make mountstat and nfs-iostat run on Python 2.6, 2.7
  and >= 3.0

Thanks! I looked at this once but was put off by all those prints. I know
there's a conversion program but I've never used it.
