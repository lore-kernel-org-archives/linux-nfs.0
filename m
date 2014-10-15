Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:52796 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609AbaJOAtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2014 20:49:31 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so167311qgd.23
        for <linux-nfs@vger.kernel.org>; Tue, 14 Oct 2014 17:49:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140917181619.GA31483@infradead.org>
References: <20140917181619.GA31483@infradead.org>
From: Steve French <smfrench@gmail.com>
Date: Tue, 14 Oct 2014 19:49:10 -0500
Message-ID: <CAH2r5mutD=JzAf0whP2OLgZVzBR_H81-rzmq_Qku2fEBofR9mA@mail.gmail.com>
Subject: Re: NFSv4.1 xfstests results
To: Christoph Hellwig <hch@infradead.org>, Anna.Schumaker@netapp.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Saw Anna's patch for xfstests go in today (thanks) so for
nfsv3/v4/v4.1 did a run from 3.17 client and saw failures on test 192
(as expected based on Christoph's earlier results) and 35 and 313
(also noted by Christoph) for NFSv4.1 (server was Fedora 20).

> Failures: generic/192 generic/313

For NFSv4.1 I saw 3 out of 55 fail
Failures: generic/035 generic/192 generic/313

For NFSv4 I saw 4 out of 55 fail
Failures: generic/011 generic/035 generic/192 generic/313

For NFSv3 I saw 3 out of 55 fail
Failures: generic/035 generic/192 generic/313

Is the test 35 failure (overwriting rename syscall test) expected (it
wasn't in Christoph's original list)? and the test 11 failure expected
(which failed on NFSv4 only)?

Test 35 output:
    --- tests/generic/035.out 2014-10-14 16:59:22.237529380 -0500
    +++ /home/sfrench/xfstests/results//NFSv41/generic/035.out.bad
2014-10-14 18:52:51.523146653 -0500
    @@ -1,3 +1,6 @@
     QA output created by 035
     overwriting regular file:
    +./tests/generic/035: line 57: src/t_rename_overwrite: No such
file or directory
     overwriting directory:
    +./tests/generic/035: line 65: src/t_rename_overwrite: No such
file or directory
    +rmdir: failed to remove '/mnt/test/8221': Directory not empty


Test 11 is dirstress (which only failed on NFSv4 for me)


-- 
Thanks,

Steve
