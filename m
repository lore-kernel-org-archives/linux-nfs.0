Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49845 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab1FKHy5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jun 2011 03:54:57 -0400
Received: by gxk21 with SMTP id 21so2181195gxk.19
        for <linux-nfs@vger.kernel.org>; Sat, 11 Jun 2011 00:54:57 -0700 (PDT)
Date: Sat, 11 Jun 2011 15:54:56 +0800
Message-ID: <BANLkTikmtvLWVRX+wBx345QR-50P_Y_g5g@mail.gmail.com>
Subject: Question about EXCHANGE_ID on server.
From: Sid Moore <learnmost@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

on Linux NFSv4.1 server, nfsd4_exchange_id() is used for creating a
new client incarnation or updating a confirmed client incarnation. if
try to update a confirmed incarnation, EXCHGID4_FLAG_CONFIRMED_R
should be set in eir_flags according to section 18.35.3, RFC5661.

but I found EXCHGID4_FLAG_CONFIRMED_R is cleared by "clid->flags =
new->cl_exchange_flags;", which is in nfsd4_set_ex_flags() called by
nfsd4_exchange_id().

so the sematics of RFC5661 is broken? am I correct?

The code that I browse was newly cloned from
git://linux-nfs.org/~bhalevy/linux-pnfs.git.
--
Sid
