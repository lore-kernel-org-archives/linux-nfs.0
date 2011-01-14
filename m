Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59250 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab1ANBN7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 20:13:59 -0500
Received: by fxm20 with SMTP id 20so2300565fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 17:13:58 -0800 (PST)
Date: Fri, 14 Jan 2011 12:13:58 +1100
Message-ID: <AANLkTin04TeswNAM89ij84YzfeTAR7rsppGyZFfq01qM@mail.gmail.com>
Subject: mac error
From: hce <webmail.hce@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am running nfs server on a CentOS 5, it works fine for all
connections from linux, windows clients. Mac clients worked fine for
coping some regular files, but it could not copy mac packaging file
with the extension *.dmg, it stuck with an error "nfs server lockd not
responding", at the same time the server got a log message of
"rpc.statd[2448]: Can't callback linux_server (100021,4), giving up".

Appreciate advice what could cause that problem and how could fix it?

Thank you.

hce
