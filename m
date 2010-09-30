Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4277 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752122Ab0I3Vhm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 17:37:42 -0400
Message-ID: <4CA50324.9000503@panasas.com>
Date: Thu, 30 Sep 2010 23:37:40 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs-all-2.6.36-rc6-2010-09-30
References: <4C7BDD8C.40509@panasas.com> <4CA31DC3.8070300@panasas.com> <4CA34830.1040703@desy.de> <4CA34883.40005@desy.de> <4CA34B93.2010100@panasas.com> <4CA44AAA.4030803@panasas.com> <4CA45462.1070503@desy.de> <4CA455C4.4030705@panasas.com>
In-Reply-To: <4CA455C4.4030705@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've rebased the following fixes (since pnfs-all-2.6.36-rc6-2010-09-29)
and released pnfs-all-2.6.36-rc6-2010-09-30

nfsd-upstream:
  Benny Halevy     a7cd1d3 nfsd4: adjust buflen for encoded attrs bitmap based on actual bitmap length
  Benny Halevy     960a019 nfsd41: mask out unsupported pnfs attributes

pnfs-submit:
  Benny Halevy     24ed91a SQUASHME: pnfs-submit: handle NULL lseg in filelayout_get_stripesize
  Bian Naimeng     1691bd5 SQUASHME: pnfs-submit: specify the layout type before initialize mountpoint

pnfs-block:
  Steve Dickson    0d4e550 SQUASHME: pnfsblock: compile error in blocklayout code

pnfsd-files:
  Benny Halevy     435c888 pnfsd: mask out unsupported pnfs attributes only when !CONFIG_PNFSD

pnfsd:
  Benny Halevy     8abfd95 SQUASHME: pnfsd: FATTR4_WORD2_LAYOUT_BLKSIZE is supported only under CONFIG_PNFSD
  Benny Halevy     04b3521 SQUASHME: pnfsd: mask out FATTR4_WORD2_LAYOUT_BLKSIZE only when !CONFIG_PNFSD

spnfs:
  Benny Halevy     b6231c5 SQUASHME: pnfsd: factor out pnfsd check_export crap out of check_export

pnfsd-lexp:
  Benny Halevy     01cda7e SQUASHME: pnfsd: factor out pnfsd check_export crap out of check_export

