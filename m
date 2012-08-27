Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailservice.tudelft.nl ([130.161.131.5]:40709 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab2H0KvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Aug 2012 06:51:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 458062B8005
	for <linux-nfs@vger.kernel.org>; Mon, 27 Aug 2012 12:20:21 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.73])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id P8mKwKs90MeB for <linux-nfs@vger.kernel.org>;
	Mon, 27 Aug 2012 12:20:20 +0200 (CEST)
Received: from smtp-a.tudelft.nl (smtp-a.tudelft.nl [130.161.180.7])
	by mx2.tudelft.nl (Postfix) with ESMTP id C73652B801D
	for <linux-nfs@vger.kernel.org>; Mon, 27 Aug 2012 12:20:20 +0200 (CEST)
Received: from [131.180.208.203] (x208203.tudelft.net [131.180.208.203])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-a.tudelft.nl (Postfix) with ESMTP id 6A4BCB3A62
	for <linux-nfs@vger.kernel.org>; Mon, 27 Aug 2012 12:20:20 +0200 (CEST)
Message-ID: <503B49E4.2050409@tudelft.nl>
Date: Mon, 27 Aug 2012 12:20:20 +0200
From: Robbert Eggermont <R.Eggermont@tudelft.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 state id errors
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

> A couple of weeks agoo we upgraded our Netapp filer to 8.1.1RC1. We have
> always had trouble with NFS and state id's. Resulting in hanging clients.

(Client: SLED11 SP2, 3.0.34-0.7-default x86_64)

The "hanging" seems to be caused by the server returning an 
NFS4ERR_BAD_STATEID(10025) status for PUTFH;LOCK and PUTFH;WRITE;GETATTR 
calls. The client is making several hundreds of these identical (same 
filehandle) calls each second.

The problem seems to be triggered by (write) actions on an open file 
when the Kerberos ticket has expired (especially for .xsession-errors 
and files opened by Firefox or Thunderbird).

When (after some time) a new valid ticket is obtained, the kernel 
reports this error:
nfs4_reclaim_open_state: unhandled error -10026. Zeroing state

Is this a client or a server problem (and is there by any chance a fix)?

Robbert

