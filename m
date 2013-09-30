Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.henderson-group.com ([62.253.225.167]:51783 "EHLO
	mailedge.henderson-group.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754023Ab3I3MXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 08:23:51 -0400
Received: from mail.henderson-group.com ([10.1.1.50])
	by mailedge.henderson-group.com (8.14.5/8.14.5) with ESMTP id r8UC758e014038
	for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 13:07:05 +0100
Received: from HGVEX01.Inside.John-Henderson.co.uk (unverified) by
    mailsweeper.henderson-group.com (Clearswift SMTPRS 5.5.0) with ESMTP
    id <Tae7b6524170a010132528@mailsweeper.henderson-group.com> for
    <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 13:08:55 +0100
From: Michael Gliwinski <Michael.Gliwinski@henderson-group.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: gss context cache
Date: Mon, 30 Sep 2013 13:06:47 +0100
Message-ID: <1702585.AG7n1MCr0K@hgis96>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

On RHEL6 nfs-utils-1.2.3-36

man rpc.gssd says it -t wasn't specified then kernel gss contexts will be 
cached for the lifettime of the Kerberos service ticket used in its creation.  
Is there a way to see the contexts + service tickets in that cache?

Also, is there any way short of rebooting the client to evict one entry from 
that cache, or even clear the cache entirely?

(looking for this as I had situations where access was denied by the NFS 
server and I could see the principal was getting mapped to nfsnobody, etc. and 
was suspecting the account was changed on the KDC and the old context/ticket 
may have been causing problems)

Thanks,
Michael


**********************************************************************************************
The information in this email is confidential and may be legally privileged.  It is intended solely for the addressee and access to the email by anyone else is unauthorised.
If you are not the intended recipient, any disclosure, copying, distribution or any action taken or omitted to be taken in reliance on it, is prohibited and may be unlawful.
When addressed to our clients, any opinions or advice contained in this e-mail are subject to the terms and conditions expressed  in the governing client engagement leter or contract.
If you have received this email in error please notify support@henderson-group.com

John Henderson (Holdings) Ltd
Registered office: 9 Hightown Avenue, Mallusk, County Antrim, Northern Ireland, BT36 4RT.
Registered in Northern Ireland
Registration Number NI010588
Vat No.: 814 6399 12
*********************************************************************************

