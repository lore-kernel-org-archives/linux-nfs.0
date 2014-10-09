Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:46797 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719AbaJIDKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Oct 2014 23:10:03 -0400
MIME-Version: 1.0
From: Steve French <smfrench@gmail.com>
Date: Wed, 8 Oct 2014 23:09:42 -0400
Message-ID: <CAH2r5mt8EfVraedY2Gi31E4xQG=p=YqtAXEoH2a+FYHdmBzbqA@mail.gmail.com>
Subject: xfstests and linux nfs testing
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Was running into a strange error with xfstests over nfs - must be
missing something obvious since I have run it various times before.

Tried the following local.config file (placed in root of xfstests directory)

FSTYP=nfs
TEST_DEV=192.168.93.152:/share-1
TEST_DIR=/mnt/test
NFS_MOUNT_OPTIONS='-ov3'

and did
./check -nfs generic/001

which should have worked fine, but it and the various other nfs
capable xfstests returned

     [not run] requires a test device

which is weird because even setting the TEST_DEV as an environment
variable xfstests still thought it wasn't set.

Anyone have a sample NFS local.config file for xfstests which works?

-- 
Thanks,

Steve
