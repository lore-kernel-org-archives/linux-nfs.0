Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:43156 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab2BMSzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 13:55:25 -0500
Message-ID: <4F395C90.8030009@fifthhorseman.net>
Date: Mon, 13 Feb 2012 13:55:12 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Reply-To: "debian-backports@lists.debian.org"
	  <debian-backports@lists.debian.org>
MIME-Version: 1.0
To: whats_up@gmx.net
CC: linux-nfs@vger.kernel.org,
        "debian-backports@lists.debian.org"
	<debian-backports@lists.debian.org>
Subject: Re: mount hangs in NFS4+Kerberos setup
References: <20120210154526.7b504146@little-poseidon> <4F35512A.9050500@steve-ss.com> <20120210184154.03fb6907@little-poseidon> <jhaq04$pev$1@ultimate100.geggus.net> <20120213195053.0db35dd9@little-poseidon>
In-Reply-To: <20120213195053.0db35dd9@little-poseidon>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/13/2012 01:50 PM, whats_up@gmx.net wrote:
> 
> - include squeeze-backports and upgrade nfs-common, nfs-kernel-server
>   to version 1.2.4 and Linux kernel to 3.2
> - replace portmap by rpcbind
> - install version 0.2.2 of libtirpc from unstable (forced new libc6)

It sounds like you'd like to request a backport of libtirpc to
squeeze-backports.  is that right?  that is best done on the debian
backports mailing list (cc'ed here)

I've set reply-to debian-backports@lists.debian.org, so please follow up
there if you'd like to see this package backported.

Regards,

	--dkg
