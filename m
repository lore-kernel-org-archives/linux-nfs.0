Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailb.microsoft.com ([131.107.115.215]:22085 "EHLO
	smtp.microsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab0KOVAb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 16:00:31 -0500
From: "Chris Rawlings (VMC Consulting Corporation)"
	<v-crawli@microsoft.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: libdevmapper check missing
Date: Mon, 15 Nov 2010 21:00:24 +0000
Message-ID: <71801D9A4C21BA4DBE850A74658897CA023390AC@TK5EX14MBXC112.redmond.corp.microsoft.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I recently built the pnfs-nfs-utils from the development repository (git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git) and ran into a minor problem with the autotools/configure scripts.  The configure scripts don't check for the existence of libdevmapper (provided by the 'device-mapper-devel' package in Fedora). The absence of the libdevmapper library causes 'make' to fail.  For reference, I used the following configure flags:

     ./configure --enable-nfsv41

-Chris Rawlings

