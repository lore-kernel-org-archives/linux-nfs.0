Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:37868 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdHCSrv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:47:51 -0400
Received: by mail-qk0-f179.google.com with SMTP id z18so12759175qka.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:47:51 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 3 Aug 2017 14:47:50 -0400
Message-ID: <CAN-5tyHVyJUBvrPZsc6Dgj-H1nrS=F1eOD+Ndhig505B_axaQA@mail.gmail.com>
Subject: nfs gss context destruction
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'd like to know what your thoughts are on the method of providing
user-driver gss context destruction.

I have read mailing list discussion
http://marc.info/?l=linux-nfs&m=138245168524204&w=2 from the earlier
attempt that Andy did in 2013. Suggestion was to propose a system call
interface to provide such functionality which I did.

I haven't had luck with VFS accepting functionality so I'm
pre-emptively asking about an alternative approach that NFS could use.
There is the original proposal to use a keyring, then there is pipe_fs
or I don't know maybe sysctl? Does one sound better than the other in
your opinion?

Thank you.
