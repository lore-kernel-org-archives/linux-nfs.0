Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62F8BC10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:01:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 251812075B
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:01:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="nGByEDBQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726536AbfDKRBw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 13:01:52 -0400
Received: from mail-ua1-f46.google.com ([209.85.222.46]:43419 "EHLO
        mail-ua1-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726106AbfDKRBw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 13:01:52 -0400
Received: by mail-ua1-f46.google.com with SMTP id n16so2266394uae.10
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 10:01:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=P6a+gsB0rOPUF+XguAtuj9IucRvzbv81qd9OuC6IBNY=;
        b=nGByEDBQZfO3gns3MhTfbdCST1NkDKaAX3pIWDyANTpIkPNRBiOMGu4+njxeYJCWWc
         jdqglHM635M4tjt2/dWim5LlbkaarEGA4FNgAzi4d7ACyuGac2Wh4jZbRRI+zxyivyyY
         PzNuGPp1U1qPNHWKlcXkR97+VTbaDJujWlqp0YCCwL+Z0mvAcPkC++tyqL7BrlK9xtxw
         /SLreutajXmwvcSkGzlqUSWrOHinlWT3G8UoWmmlf0HY0v/AKsUPE+3ywF9EqSoW7JV2
         v/yfbdA13qwYLtOTQlg2in46np1e1fFFnMT+2y4NIcH/fS5pMkevFbiOzCayy4Z6c8JE
         IGJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=P6a+gsB0rOPUF+XguAtuj9IucRvzbv81qd9OuC6IBNY=;
        b=OMaKG739uPS1h182KWqUNU2xB8pDYkLCIVq6i5Nc/057WII6+YLaAYpbEkzOFmFptG
         GKLUlVt2LaHqx7nU8+I1E3UAjbJIpOxTslXuS/1R08MUf2iyNZGx76/jN8LGNj8tfxAp
         YMwGjCjHO70AKxsLmJPcUPBkYNmGoEV7rg5PmM3PLCpTqIYBweWU2lzW5lMqLb4dodum
         5FK39tLOoY/xjM3Go/zeAv2vO2l5HLEoQ7ZAcY80BoYpLrntpCSeSGPJuL6eB4Ug2iaG
         PdR/PirliNIyr45QoQ7XSMuf2EJTtOY64Mb6wOXcMm+6La4kxak955kKPYFEA7SXeryo
         gmww==
X-Gm-Message-State: APjAAAWM4do3wIb8a9HCj7nu0bqFJ7xYQpK30+LQladR33hMaiR0nyhV
        kKJL97kMHxx+dSD2+FQzp3Yf2+VL3lYeMFlVFsWKdBU3
X-Google-Smtp-Source: APXvYqyHjC8q4/H8eBFJfVjJcV3AwMWp8I1gWkGX5AQYSmuNhtBSplJFcYe9/fm5mRe555+AzoGj7KUJ+aOiluxtKWM=
X-Received: by 2002:ab0:c01:: with SMTP id a1mr7516284uak.116.1555002110792;
 Thu, 11 Apr 2019 10:01:50 -0700 (PDT)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Thu, 11 Apr 2019 13:01:39 -0400
Message-ID: <CAN-5tyHGLTFmd1t9Bn4VqbLFsnvTMJYd-dBzrn9mP-Tn7g8XVg@mail.gmail.com>
Subject: discuss NFS xfstest failures
To:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi folks,

We have some output at the wiki --
https://wiki.linux-nfs.org/wiki/index.php/Xfstests -- capturing a data
point of failures (for 4.16 kernel). However, I see many more failures
with the current (5.1-rc1). Wiki output should probably be updated
since xfstest has now 500+ tests. I have done my best to go over the
failures and provide some summary and comments. I'd like to see if the
community has any comments. Anybody else would like to share their
outputs from the xfstests that show other failures?

nfsv4.1
Failures: generic/035 generic/075 generic/091 generic/112 generic/263
generic/294 generic/465 generic/484 nfs/001
Failed 9 of 429 tests
nfsv4.0
Failures: generic/035 generic/075 generic/091 generic/112 generic/263
generic/294 generic/426 generic/465 generic/467 generic/477
generic/484
Failed 11 of 429 tests
nfsv3
Failures: generic/035 generic/258 generic/294 generic/465 generic/467
generic/477 generic/484
Failed 7 of 429 tests

I will first list the ones that are not on the wiki (and grouped by version=
):

nfs4.1
--- [FIXED] nfs/001 =E2=80=93 a regression problem has been resolved with t=
he
latest patch from Chuck addressing the issue.
--- [EXPECTED] generic/075, generic/091, generic/112, generic/263 =E2=80=93
expected failure. Because copy_file_range() is called and passes in as
input and output the same file which is not allowed by the NFSv4.2
spec.
--- [VFS problem] generic/484 this is a VFS failure not to preserve
the lock across execve (as the NFS is just a hook into the VFS)
--- [VFS problem] generic/294 this is again VFS issue that for returns
an error that the test doesn=E2=80=99t expect (test expects EEXIST and gets
ROFS). This error is set by the VFS function finish_open(). However, I
do see some test itself weirdness. The test attempts to remount to a
read-only FS in the middle. Which only translates to new PUTROOTFH. A
test tries to create a file which translates to an NFS operation that
succeeds but the internally VFS fails it as ROFS but file is left
created on the file server.

nfs4.0
--- [FIXED] generic/075, generic/091, generic/112, generic/263 =E2=80=93 in
4.0 same function is called and same check that in and out file is the
same and get EINVAL error failing the test. There is a proposed fix
upstream.
--- generic/484 same as 4.1
--- generic/294 same as 4.1

The next tests were present in wiki
--- [EXPECTED] generic/258 (v3) failure only. This is expected because
nfstime3 spec structure defines seconds as =E2=80=9Cu32=E2=80=9D and nfstes=
t4 spec
structure defines as =E2=80=9Cu64=E2=80=9D. So when a large timestamp is se=
t in the
test, v3 wraps it around.
--- [?] generic 426/467/477 (open by handle failures all in v4.0 and
2-out-of-3 in v3, all pass in 4.1. note 426 passes in v3 which is
surprising and makes me think why should 4.0 fail in this case).
Perhaps because 4.0 doesn't support CLAIM_FH this could be considered
expected. but something is fishy here.
--- generic/035 not quiet sure of the exact reason so let's call it expecte=
d
--- generic/465 not quiet sure of the exact reason so let's call it expecte=
d

As an example, wiki listed a test which probably should have
definitely been running since it's NFS (but wasn't due to a missed
step in a setup)
"nfs/001 [not run] nfs4_setfacl utility required, skipped this test"
It makes me question how many other [not run] tests could also
problems and should have run. Anybody has any ideas how we can get a
'golden' output of what tests are applicable to NFS?
