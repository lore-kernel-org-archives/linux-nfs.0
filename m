Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:56387 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab0IOOmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 10:42:47 -0400
Date: Wed, 15 Sep 2010 10:42:45 -0400
From: Jim Rees <rees@umich.edu>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: Benny Halevy <bhalevy@panasas.com>, peter honeyman <honey@citi.umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: Deploying a pNFS / LAYOUT4_BLOCK_VOLUME configuration
Message-ID: <20100915144245.GB30965@merit.edu>
References: <4C8F6D39.2070406@cea.fr>
 <4C8F80DA.4030607@panasas.com>
 <20100915140429.GA30887@merit.edu>
 <4C90D78F.5000307@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C90D78F.5000307@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

DENIEL Philippe wrote:

  Apparently writing to /proc/fs/pnfs_block/ctl does not work. Do you
  have an idea on what I should do to fix this ?

I have not worked with the server side but will be in the coming months.
Maybe someone on the list can help.

  >I have added a section on the block layout client to the Fedora client setup
  >wiki page:
  >
  >http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
  Is there a layoutdriver to modprobe on the client or is it embedded
  in the kernel itself ?

You could build it in but I normally build it as a module.  The startup
script assumes it's a module and probes it:

fedora# grep blocklayoutdriver /etc/init.d/blkmapd
        modprobe -q blocklayoutdriver
fedora#

Right now the nfs-utils rpm doesn't install the startup script.  I'll fix
this but for now just copy it from the source:

cp nfs-utils/utils/blkmapd/etc/initd/initd.redhat /etc/init.d/blkmapd
chmod +x /etc/init.d/blkmapd
