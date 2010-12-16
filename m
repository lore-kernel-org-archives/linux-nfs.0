Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out.good-with-numbers.com ([64.142.29.24]:2980 "EHLO
	out.good-with-numbers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab0LPXrH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:47:07 -0500
Date: Thu, 16 Dec 2010 15:06:22 -0800
From: Mike <debian@good-with-numbers.com>
To: linux-nfs@vger.kernel.org
Subject: nfs-common needed on NFS-rooted client?
Message-ID: <20101216230622.GA23016@adsl-64-142-29-25.sonic.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For a client with an NFS root and no other NFS mounts, is it necessary
to have the utilities found in the Debian nfs-common package
<http://packages.debian.org/squeeze/nfs-common>?  Seems to be working
fine without.
