Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from devi.upf.edu ([193.145.56.107]:56343 "EHLO devi.upf.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754934Ab1BHSHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 13:07:16 -0500
Received: from devi.upf.edu (localhost [127.0.0.1])
	by devi.upf.edu (8.13.6/8.13.6) with ESMTP id p18I7Aqd000887
	for <linux-nfs@vger.kernel.org>; Tue, 8 Feb 2011 19:07:12 +0100
From: "Txema Heredia" <txema.heredia@upf.edu>
To: "'Txema Heredia Genestar'" <txema.heredia@upf.edu>,
        "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <4D2DE18D.40604@upf.edu> <20110112183557.GB11718@fieldses.org> <4D2F1ECA.50703@upf.edu> <20110113161913.GG20946@fieldses.org> <4D2F3583.8090502@upf.edu> <20110113180534.GK20946@fieldses.org> <4D303D55.1080908@upf.edu>
Subject: RE: NFSv4 memory allocation bug?
Date: Tue, 8 Feb 2011 19:07:08 +0100
Message-ID: <B5CA5C80A1BA4CFAA7CBB56F752F6337@ws075402>
Content-Type: text/plain;
	charset="us-ascii"
In-Reply-To: <4D303D55.1080908@upf.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

After a month or so struggling with this, and some other problems with NFSD
in my "old" kernel (2.6.16.60-0.39.3-smp) related with MTUs larger than 1500
stalling the server, I think I have found something related with my
inability to serve v4 filesystems:

In /usr/src/linux/include/linux/nfsd/const.h there is this defined:
/*
 * Maximum protocol version supported by knfsd
 */
#define NFSSVC_MAXVERS          3

And in /usr/src/linux/fs/nfsd/nfsctl.c we can find this:
err = -EINVAL;
if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
   goto out;
...
out:
        return err;


And I found exactly the same in 2.6.34.7

Is this "real" or some old thing that is no longer used and I shouldn't
worry about?


Thanks in advance,

Txema


