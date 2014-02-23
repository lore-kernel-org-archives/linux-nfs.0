Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:40743 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaBWQl2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Feb 2014 11:41:28 -0500
Received: by mail-ig0-f178.google.com with SMTP id h18so2949049igc.5
        for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 08:41:27 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: 
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de>
Date: Sun, 23 Feb 2014 11:41:26 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <94863747-3B23-4534-8990-F04F0C8D54DE@gmail.com>
References: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 23, 2014, at 11:22, tigran.mkrtchyan@desy.de wrote:

> to me it's unclear, why a SETATTR  always follows an OPEN, even in case of
> EXCLUSIVE4_1. With this fix, I get desired behavior.

Yes, but that fix risks incurring an NFS4ERR_INVAL from which we cannot recover because it does not include the mandatory check for the allowed set of attributes.
Please see RFC5661 section 18.16.3 about the client side use of ‘suppattr_exclcreat’ .

Cheers,
  Trond