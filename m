Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45092 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab1FHSwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 14:52:20 -0400
Date: Wed, 8 Jun 2011 14:52:19 -0400
From: Jim Rees <rees@umich.edu>
To: Ben Greear <greearb@candelatech.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: What is proper kernel tree to develop against?
Message-ID: <20110608185219.GD3513@merit.edu>
References: <4DEFC244.2040306@candelatech.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DEFC244.2040306@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ben Greear wrote:

  What kernel tree should I use to develop NFS & RPC patches
  for possible upstream acceptance?

I think for the stuff you're doing it would just be the upstream git tree at
kernel.org.  Note that nfs-utils is separate.

Has anyone pointed you to the wiki?  I think it answers many of these
questions, although it seems heavily slanted towards pnfs.

http://wiki.linux-nfs.org/wiki/index.php/Main_Page
