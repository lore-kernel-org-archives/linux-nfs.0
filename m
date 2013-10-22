Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:50057 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905Ab3JVAVT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 20:21:19 -0400
Date: Mon, 21 Oct 2013 20:20:51 -0400
From: Jim Rees <rees@umich.edu>
To: Ben Greear <greearb@candelatech.com>
Cc: Weston Andros Adamson <dros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
Message-ID: <20131022002051.GA13539@umich.edu>
References: <52659D69.1020609@candelatech.com>
 <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
 <5265BECD.1060601@candelatech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5265BECD.1060601@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Possibly dumb question, are you sure your srcaddr option works for all
protocols involved, including portmap, mount, and nfs?
