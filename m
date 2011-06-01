Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52746 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab1FAHns (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 03:43:48 -0400
Received: by gyd10 with SMTP id 10so2098381gyd.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2011 00:43:47 -0700 (PDT)
Date: Wed, 1 Jun 2011 11:43:47 +0400
Message-ID: <BANLkTinFR06gifZxx9f8Go2ngjm6TYNayw@mail.gmail.com>
Subject: Regression in current master
From: Pavel Shilovsky <piastryyy@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all!

Commit 9274e94db85bac04e170414cb8e0f4be271cde90
(http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=9274e94db85bac04e170414cb8e0f4be271cde90)
caused the regression when --manage-gids option is enabled: a user
doesn't get group list through getgrouplist when auth_unix_gid is
called twice. When I remove static attributes from gid_t *groups and
int groups_len, it works good.

-- 
Best regards,
Pavel Shilovsky.
