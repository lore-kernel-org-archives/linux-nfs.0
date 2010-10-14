Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63883 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab0JNMiW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 08:38:22 -0400
Received: by wyb28 with SMTP id 28so2052248wyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 05:38:21 -0700 (PDT)
Date: Thu, 14 Oct 2010 08:38:21 -0400
Message-ID: <AANLkTim975UbEmeNSSS0awLSou151rr7=DpRxxw6trdn@mail.gmail.com>
Subject: Thread scheduling issues
From: Lyle Seaman <lyleseaman@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi guys.  I've been trying to figure out a performance problem with
some of my production servers, and I have run into something that
strikes me as odd.  Is this the right place for discussion of bugs in
sunrpc/svc_xprt.c, or is there a better place?
