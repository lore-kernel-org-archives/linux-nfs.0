Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:51434 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab2LSTa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Dec 2012 14:30:58 -0500
Date: Wed, 19 Dec 2012 14:30:49 -0500
From: Jim Rees <rees@umich.edu>
To: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [3.6.11] NFS: Cache request denied due to non-unique superblock
 keys.
Message-ID: <20121219193049.GA17560@umich.edu>
References: <6078496.RFsWrNWv86@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6078496.RFsWrNWv86@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paweł Sikora wrote:

  Hi,
  
  i'm testing the 3.6.11 kernel on some small internal nfs network (1 server <-> 2 clients)
  and observing such info in dmesg on the client side. could you put some
  light on this dmesg entry?

Are you mounting the same file system more than once? Why? I thought I
remembered a mount option to uniquify the mounts but I can't find it now.
