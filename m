Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:57646 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932343Ab3HGU0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 16:26:21 -0400
Date: Wed, 7 Aug 2013 16:26:17 -0400
From: Jim Rees <rees@umich.edu>
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: bisecting an NFS issue prevented by fs/nfsd/nfs4recover.c:1414
Message-ID: <20130807202617.GA29924@umich.edu>
References: <5202AB04.9010006@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <5202AB04.9010006@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Toralf Förster wrote:

  I'm trying to bisect a NFS + EXT3/4 + loop device issue introduced
  probably between v3.8 and v3.10. Unfortunately my test systems (2 user
  mode linux images) often fails to reproduce the origin issue due to a
  crash in at another place.
  
  Now I'm wondering if somebody can point me to (few) patches, which I could
  just apply during bisect to avoid running into the "false" bug.

It could be this:

7255e71 nfsd: fix oops when legacy_recdir_name_error is passed a -ENOENT error
