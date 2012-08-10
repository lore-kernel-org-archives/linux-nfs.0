Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:54486 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab2HJMSQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 08:18:16 -0400
Date: Fri, 10 Aug 2012 08:18:08 -0400
From: Jim Rees <rees@umich.edu>
To: Johannes Schild <JSchild@gmx.de>
Cc: Peng Tao <tao.peng@emc.com>, linux-nfs@vger.kernel.org
Subject: Re: RE: Blocklayout
Message-ID: <20120810121808.GA9817@umich.edu>
References: <20120808182622.177380@gmx.net>
 <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
 <20120809152744.149360@gmx.net>
 <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
 <20120810074818.119500@gmx.net>
 <CA+a=Yy6C-d82MR6Lun4sRcJ0euBBpf0Ra3cHDnQ8eKENi5eU2Q@mail.gmail.com>
 <20120810092016.177360@gmx.net>
 <CA+a=Yy58ZgG1zoUP4633u6uuZ22hnpuqjS1xa4j3S8R=9=zEUA@mail.gmail.com>
 <20120810120635.268340@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120810120635.268340@gmx.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Johannes Schild wrote:

  Hi Tao,
  
  the output von the server (ctl) looks for *me* good...
  
  http://www.mozilla.org/en-US/firefox/update/
  
  [root@fedorapnfs2 sbin]# /root/ctl/ctl -u
  [root@fedorapnfs2 sbin]# Processing: MSG_VERS    : Version: 8
  Processing: MSG_VERS    : Version: 8
  Processing: MSG_DMCHK   : DM Volume: True
  Processing: MSG_DMGET   : Vol info: 0 6291456 striped 2 128 8:17 2048 8:33 2048
      major 8, minor 17
      major 8, minor 33
  Processing: MSG_GETSIG  : get_sig: 8:17: get_sig: Got sig at: 1, within sector 56, len 16
      e9 91 e5 1c d7 cb 20 41   ad d1 61 f9 a7 30 5e fb   
  Processing: MSG_GETSLICE: get_slice: 8:17: Dev: 8:17, Start: 34, Length: 4196285
  Processing: MSG_GETSIG  : get_sig: 8:33: get_sig: Got sig at: 1, within sector 56, len 16
      9b 0d 30 b8 42 68 0a 4c   95 52 ed 5f d7 46 49 ed   
  Processing: MSG_GETSLICE: get_slice: 8:33: Dev: 8:33, Start: 34, Length: 4196285

I'm not familiar with this server, but all I see here is slices from two
disks.  The blkmapd output shows the same thing.  Normally these would be
striped or catenated to form the file system device.  What device topology
do you think you're exporting?
