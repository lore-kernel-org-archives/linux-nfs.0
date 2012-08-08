Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:55026 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037Ab2HHQjW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 12:39:22 -0400
Date: Wed, 8 Aug 2012 12:39:16 -0400
From: Jim Rees <rees@umich.edu>
To: Johannes Schild <JSchild@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Blocklayout
Message-ID: <20120808163916.GA24539@umich.edu>
References: <20120808155829.177400@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120808155829.177400@gmx.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Johannes Schild wrote:

  on client-side i did the instructions from the howto. But the output from 
  blkmpad looks a little bit curious:

Your blkmapd is out of date.  You need 0001-remove-pretty_sig.patch from the
wiki.
