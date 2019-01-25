Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77CD0C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:07:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 348C621855
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 22:07:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XLfCjycr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726179AbfAYWHp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 17:07:45 -0500
Received: from mail-pl1-f194.google.com ([209.85.214.194]:33206 "EHLO
        mail-pl1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726218AbfAYWHp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 17:07:45 -0500
Received: by mail-pl1-f194.google.com with SMTP id z23so5167342plo.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 14:07:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=HMp0x+OV8VK/fkl3dKLqjJldUGkc/1pCmwlHMas1xqI=;
        b=XLfCjycryT9oxJY4dzgsdoIkMKUdVNX9mIzLzbq0kOAqSIcqA/U9QuDZXx+yqapVZZ
         /I0bP9izNeDVDgcN/cbD8lmisXIRD7kEuHvzde/BJM1xC7gL3131OVUzE9w/2wpUL0d6
         O+h6xVsuia2tTQMwnkcb4A8hLSkvSDoyzaqMI+7NCJB6HWMWsJU0msfEi3TBcC2xJJZp
         BfRD87seWIc4AvxSjHcUC167lEbiMiNgQNyAJiRfjmiP4175oYzSfrtoLw7kJCnzsJpj
         uc9Cf/OuvGg846fn1Bi0068HjNurdgawkLAMSLpU1EtbXFvuCmGJLrikTDfS07ZGij6X
         6dsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=HMp0x+OV8VK/fkl3dKLqjJldUGkc/1pCmwlHMas1xqI=;
        b=pPWDQxnF4vaDDJTWcRwa5u8olkNHodONQkU1ttOHHLK3B/Vfb158sAJJ4DvnCN/M4e
         HFrRRxiZhqFcuP518JUxTXUJ+Er+PWELZQ3Vj8BOkNADVh/AqgKS6yajjJOcSp3V/xgD
         Wy4rxx7Hy0AOou01TBb7ersPHUwDwkW4Y4h+2L6eXt8fJ19FUHsDn7pasoaPXVtVLYWF
         VKjW7Db7jbndkc+iVNGudErC6RwMGrVLaTZUpll8Q9w/bev66OxWIx0xfW1DZsgalAYz
         6IftZJeqGtKZcNPXWEg99mfLUqQmnMRtGjp8DZClse7l32eCbR6f/bPVHh/G1NdG1d4c
         nFdg==
X-Gm-Message-State: AJcUukdY3rjceujdiXA2xFw/ZXQLiREqJkBSH4TLlUUqLKbeM2B8a3mr
        +LcA/IYM71lrXMhG5xJFNJRPY2wP
X-Google-Smtp-Source: ALg8bN48slRFBHhA/ZagF40WTdaZK+eEd5Agzn8ez9to+uPZll1JB9VMupY3ShB9pFHDTfgpBjyT3A==
X-Received: by 2002:a17:902:680f:: with SMTP id h15mr12594091plk.40.1548454064317;
        Fri, 25 Jan 2019 14:07:44 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id s190sm34802212pfb.103.2019.01.25.14.07.43
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 14:07:43 -0800 (PST)
Subject: [PATCH RFC 0/5] Ideas for new NFS and RPC trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 25 Jan 2019 17:07:22 -0500
Message-ID: <154845390550.70638.13083502621745566898.stgit@seurat.1015granger.net>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Here are some trace point-related changes that could improve the
observability of NFS and RPC operation. Interested in comments.

---

Chuck Lever (5):
      SUNRPC: Add xdr_stream::rqst field
      SUNRPC: Add XDR overflow trace event
      SUNRPC: Add trace event that reports reply page vector alignment
      NFS: Remove print_overflow_msg()
      NFS: Add trace events to report non-zero NFS status codes


 fs/lockd/clnt4xdr.c                    |   14 -
 fs/lockd/clntxdr.c                     |   14 -
 fs/nfs/callback_xdr.c                  |   64 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c |    2 
 fs/nfs/nfs2xdr.c                       |   91 ++----
 fs/nfs/nfs3xdr.c                       |  170 ++++--------
 fs/nfs/nfs42xdr.c                      |   21 -
 fs/nfs/nfs4trace.h                     |   25 ++
 fs/nfs/nfs4xdr.c                       |  463 +++++++++-----------------------
 fs/nfs/nfstrace.c                      |    1 
 fs/nfs/nfstrace.h                      |   85 ++++++
 fs/nfsd/nfs4callback.c                 |   13 -
 include/linux/sunrpc/xdr.h             |    8 -
 include/trace/events/sunrpc.h          |  126 +++++++++
 net/sunrpc/auth.c                      |    4 
 net/sunrpc/auth_gss/auth_gss.c         |    4 
 net/sunrpc/xdr.c                       |   69 ++++-
 net/sunrpc/xprtrdma/backchannel.c      |    2 
 net/sunrpc/xprtrdma/rpc_rdma.c         |    4 
 19 files changed, 548 insertions(+), 632 deletions(-)

--
Chuck Lever
