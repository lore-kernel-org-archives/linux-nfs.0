Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:53532 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757351AbaAIAgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 19:36:23 -0500
Date: Wed, 8 Jan 2014 19:36:18 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] statd: include stdlib.h in simu.c
Message-ID: <20140109003618.GA6055@umich.edu>
References: <1389225273-24273-1-git-send-email-rees@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1389225273-24273-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:

  Prevents undefined ref to NULL.
  
You can probably ignore this. I missed an autogen.
