Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2F3FC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 12:35:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B4D5B2184D
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 12:35:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i4lX1X+X"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727941AbfCTMfH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 08:35:07 -0400
Received: from mail-lf1-f53.google.com ([209.85.167.53]:41721 "EHLO
        mail-lf1-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727471AbfCTMfH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2019 08:35:07 -0400
Received: by mail-lf1-f53.google.com with SMTP id 10so1733892lfr.8
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 05:35:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=5xzrbRmlmu2t9A64unRCX3sxxP63tnIi8MDjYv+5r5c=;
        b=i4lX1X+XXFwFRmmtgMESfUcs2rI72XMNjneiM5P2CGJ35XeJNXFum+KYT2dZF4ht3P
         JMs336zaXHDHd4cQw0FMA6j2IH7sfZbBCPkRekEB5vRvui1CN+HKiylm4K0XeR1Fcn30
         khhO/eyFYvXmtbqBqPN61tGFr/tRhgPMF+Bux75qLC0Mf8mxj06So2kv8BsOmFmpy1OS
         1pSap1NPZF7B7Wl3NACh6svLqpZZK3p6cL73Qdt2Qq0RVhSg/u+/vWSFAjklmFsJTGcH
         MNdQYax7p6zrcK2akifQVUzuY9jE4PqqjTe1pvvxA2KVs/UkVMPtTIDCgsLz/pHqDMgX
         O0tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=5xzrbRmlmu2t9A64unRCX3sxxP63tnIi8MDjYv+5r5c=;
        b=TKZTAKtWAXCHZB0HrlJfWjczzCJ9Vn+KSE+CQQD7KcbUmmRTrTglYHqGAuUjvmlSp2
         ZjJqKZ471X6Z1onu/z/OST4Ul1QSDEDCiyPWnzR67oSjg92XREt2fll2ZxRsgl7jqiPl
         mg4lkzXCoQHVxheEForp7p+PLy9atC1yjyDhoXlDAzxwOT9616kYN6PYW+4SWdlqbJ6N
         SxoNKHO0vAqPIhkpL51iy7NIwcQzHAWhBXxa6Uu921M8IyOKqIZfnIFReTjFtShia33j
         zZemoQoqRbx2PtLbnEVGypa1meIVtQazi0j9dFEenI7BuSULxzLU/SMTQvny59bWgnOL
         Mc3A==
X-Gm-Message-State: APjAAAUZmXVlBiIyOZobxZfzQDVQsRtORnLRcUjICUxQNYJzZ+ldPV77
        sV9Gf6e+wZf2BwvjG3YeBP1DAcjAaK/AeQYgLA1PqJo4
X-Google-Smtp-Source: APXvYqxdKHjtrU2R8FQlHABdg8VIb4NMn564wc2IVG1ETwPMzgK5VVHbzxGcu/S9r4nQlSFzR813bXRuvZIt7cLZjhw=
X-Received: by 2002:ac2:4142:: with SMTP id c2mr16203108lfi.84.1553085305281;
 Wed, 20 Mar 2019 05:35:05 -0700 (PDT)
MIME-Version: 1.0
From:   James Pearson <jcpearson@gmail.com>
Date:   Wed, 20 Mar 2019 12:34:54 +0000
Message-ID: <CAK3fRr9qji9_B8LnYedttqQk+q-Q_wYKH_KVDJAK3Bfo15fusA@mail.gmail.com>
Subject: NFSv3 mount hangs on CentOS 7.4
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We have a number of specialized workstations running CentOS 7.4
(kernel 3.10.0-693.11.1.el7.x86_64) that are both NFSv3 clients and
servers- i.e. they can mount each other's exports via autofs -
however, occasionally the mount process hangs

Each workstation has 4 exports, 2 of the exports are subdirectories of
the root disk - these are exported with the 'sync' option , the other
2 exports are the mount points of separate file systems - exported
with the 'async' option. All are XFS file systems

The mount process hang only happens with the exports from the root
disk - and once a mount hangs on one of these exports, a mount of the
other export from the root disk also hangs - but mounting the other 2
exports are fine

The problem can occur on any of the workstations mounting any of the
other workstations exports

We can temporary fix the problem by running 'exportfs -f' on the server

Running tcpdump on the client (or server) when attempting a mount when
in this state shows that the client sends an FSINFO call, but doesn't
get a reply - it then retransmits the FSINFO call and sends another
FSINFO call about 18 seconds later - but no replies - which I'm
guessing is significant?

Unfortunately, it is not straight forward to upgrade the kernel on
these workstations - so difficult to test if a newer kernel would fix
the issue ...

Is anyone able to suggest any other debugging steps we can take to
find out what the issue might be?

Thanks

James Pearson
