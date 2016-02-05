Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35143 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596AbcBEPhx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 10:37:53 -0500
Received: by mail-io0-f174.google.com with SMTP id d63so132301500ioj.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 07:37:53 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 5 Feb 2016 10:37:52 -0500
Message-ID: <CAN-5tyFJNCsSM=pccUnQmtq6ZMDdHNAmxOBZGYV2_0iNzfLsMQ@mail.gmail.com>
Subject: Question about XID use in sunrpc
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a question regarding the implementation of sunrpc use of XID
when the client receives an AUTH_ERROR. The code (clnt.c line 1933)
explicitly comments that a new XID should be acquired and releases the
currently rpc task (and gets a new one). Why is that? Since the
operation is "replayed" but with the new credentials, why shouldn't
the same XID be used?

The RPC RFC says that XID is used by the server to detect
retransmissions. It's not clear if in the specs means "retransmission"
== tcp retransmissions. If so then it explains why the client uses the
same XID.

Thank you.
