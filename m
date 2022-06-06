Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A78EC433EF
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jun 2022 18:14:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231269AbiFFSOH convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jun 2022 14:14:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41912 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229504AbiFFSOG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2022 14:14:06 -0400
Received: from mail.linux-ng.de (srv.linux-ng.de [5.9.18.165])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id C50D05E172
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jun 2022 11:14:05 -0700 (PDT)
Received: from cloud.linux-ng.de (srv.linux-ng.de [IPv6:2a01:4f8:160:92e6::2])
        by mail.linux-ng.de (Postfix) with ESMTPSA id 256D983C4290
        for <linux-nfs@vger.kernel.org>; Mon,  6 Jun 2022 20:14:05 +0200 (CEST)
MIME-Version: 1.0
Date:   Mon, 06 Jun 2022 18:14:05 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
X-Mailer: RainLoop/1.16.0
From:   marcel@linux-ng.de
Message-ID: <bf4aa2c82bfef19304d7a458a2a8fb28@linux-ng.de>
Subject: nfs-utils: rpc.svcgssd bug reading /etc/nfs.conf
To:     linux-nfs@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi there,

please don't hesitate to direct me somewhere else in case this is not the right place to report
bugs concerning nfs-utils.

I found a bug in nfs-utils concerning the rpc.svcgssd daemon while I was trying to set the
principal name in /etc/nfs.conf:

[svcgssd]
principal=nfs/myhost.mydomain.de@MYDOMAIN.DE

However rpc.svcgssd refused to start - complaining about not being able to find the principal in
the keytab.
When specified on command line (using the -p option) things worked however.

So I took a look at the code and found the problem in nfs-utils-2.6.1/utils/gssd/svcgssd.c.
The problem seems to be here:

/* We don't need the config anymore */
conf_cleanup();

This is called right after parsing the config file(s), but before calling gssd_acquire_cred().
At the time it is called the variable "principal" does no longer contain the data read from the
config file.

Moving conf_cleanup() to the end of the code helps.

As I first encountered this on Ubuntu 22.04 I also opened a Launchpad bug report:
s. https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1977745

Maybe someone can fix this for the next release.

Best regards,
Marcel
