Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35662 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcFQHJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 03:09:10 -0400
Received: by mail-oi0-f43.google.com with SMTP id w5so104821439oib.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2016 00:09:10 -0700 (PDT)
MIME-Version: 1.0
From: Martin Houry <martinhoury@gmail.com>
Date: Fri, 17 Jun 2016 09:08:45 +0200
Message-ID: <CAEUt8VKFwMMkUCnbjy1m5Zht3yH83HMOo2T12oCVLwfzEP6D1Q@mail.gmail.com>
Subject: Question : Session trunking fail-over
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I have a question about Session trunking.
In the RFC 5661 the  "2.10.13.1.2.Connection Loss" specify how to do
if the LAST connection of the session is lost. There no specification
when the lost connection is not the last connection of the session. Is
there a fail-over mecanism for the session trunking connection loss?

Thank you.
Martin
