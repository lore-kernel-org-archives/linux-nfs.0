Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:56113 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbAWFXm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 00:23:42 -0500
MIME-Version: 1.0
From: Steve French <smfrench@gmail.com>
Date: Thu, 22 Jan 2015 23:23:21 -0600
Message-ID: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com>
Subject: xfstest generic/299
To: fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Noticed test generic/299 failing over NFS (v4.1 dialect) with the error

"[not run] /usr/bin/fio too old"

fio-2.1.11 version (which is what is installed on current Ubuntu) is
presumably not too old

and the earlier test bug noticed in testing ext4 where NUM_JOBS was
not defined in this testcase does not seem to be the issue (it fails
the same way even if I set NUM_JOBS=4 manually in tests/generic/299)

Should test 299 work over NFS?

-- 
Thanks,

Steve
