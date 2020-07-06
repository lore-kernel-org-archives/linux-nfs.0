Return-Path: <SRS0=KEbm=AR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED81FC433DF
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jul 2020 10:17:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D7F2F2075B
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jul 2020 10:17:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728813AbgGFKRU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jul 2020 06:17:20 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44890 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728734AbgGFKRO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2020 06:17:14 -0400
X-Greylist: delayed 501 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Mon, 06 Jul 2020 03:17:13 PDT
Received: from mail.sernet.de (mail.sernet.de [IPv6:2a0a:a3c0:0:25::217:2])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9A9E2C061794
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2020 03:17:13 -0700 (PDT)
Received: from intern.sernet.de by mail.sernet.de
        with esmtps (Exim 4.92 #3)
        id 1jsOBT-0006P1-Ce; Mon, 06 Jul 2020 12:17:11 +0200
Received: by intern.sernet.de
        id 1jsOBT-00069l-5d; Mon, 06 Jul 2020 12:17:11 +0200
Received: from bjacke by pell.sernet.de with local (Exim 4.93)
        (envelope-from <bjacke@sernet.de>)
        id 1jsOBT-0061w7-13; Mon, 06 Jul 2020 12:17:11 +0200
Date:   Mon, 6 Jul 2020 12:17:11 +0200
From:   =?iso-8859-1?Q?Bj=F6rn?= JACKE <bjacke@SerNet.DE>
To:     "Kraus, Sebastian" <sebastian.kraus@tu-berlin.de>
Cc:     "samba@lists.samba.org" <samba@lists.samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [Samba] Multiprotocol File Sharing via NFSv4 and Samba
Message-ID: <20200706101711.GB1437261@sernet.de>
Mail-Followup-To: "Kraus, Sebastian" <sebastian.kraus@tu-berlin.de>,
        "samba@lists.samba.org" <samba@lists.samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <3c399c3523674ec7b650b647179d7c96@tu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3c399c3523674ec7b650b647179d7c96@tu-berlin.de>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2020-07-02 at 18:04 +0000 Kraus, Sebastian via samba sent off:
> are there any non-commercial solutions (apart from solutions like Dell EMC, IBM and NetApp) around that allow to simultaneously access the same file system via NFSv4 and Samba exports in a (nearly) non-conflicting manner, especially w.r.t. to NFSv4/Windows ACL incompatibilities?

related to this topic the NFS4 ACL overview in the wiki:
https://wiki.samba.org/index.php/NFS4_ACL_overview

Björn
