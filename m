Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:44911 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab1GCNCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jul 2011 09:02:49 -0400
Date: Sun, 3 Jul 2011 09:02:37 -0400
From: Jim Rees <rees@umich.edu>
To: Luk Claes <luk@debian.org>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
Message-ID: <20110703130237.GA9889@merit.edu>
References: <1309617149-3993-1-git-send-email-luk@debian.org>
 <20110703150421.2db09d94@notabene.brown>
 <4E100E17.5000304@debian.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E100E17.5000304@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Luk Claes wrote:

  > So if the version number is not recognised - e.g. it was written in Sanskrit
  > rather than arabic numberals, it is assumed to be a future version, not a
  > past version.
  > 
  >  https://lkml.org/lkml/2011/6/14/293
  
  Ah, not a bad idea. In that case a parse error can be distinguished from
  other errors. Would 'return -1' do the expected or will it give a
  compiler warning/error we should avoid?

You can't return -1 from a function returning unsigned int.  I think you
want to return something like

MAKE_VERSION(9999, 255, 255)
