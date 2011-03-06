Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:33925 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab1CFBvN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Mar 2011 20:51:13 -0500
Date: Sat, 5 Mar 2011 20:51:06 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Masatake YAMATO <yamato@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] Read /etc/exports.d/*.export as extra export files
Message-ID: <20110306015106.GA23388@merit.edu>
References: <20110217.215900.388120588347145930.yamato@redhat.com>
 <4D72BD33.70208@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D72BD33.70208@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  Now, I realize you added the ".export" explanation to the man page 
  but is there a particular reason why file in that directory have 
  to end with ".export"? Out of "easy of use" sake, should any 
  and all files that exist in that directory be expected to 
  be exports files?

I don't know if that's the best way to do it, but I think it would be useful
to have a way to keep files in the directory that don't get automatically
read.  As an analogy, I have the following files in my /etc/init:

portmap.conf           This is the real one that gets used
portmap.conf~          This is a backup file produced by emacs
portmap.conf-20100603  This is the file that came with my distro

Only the first one gets used, which is what I want, because it's the only
one ending in ".conf".
