Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4810 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614Ab2LSTfv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 14:35:51 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: =?utf-7?B?UGF3ZStBVUktIFNpa29yYQ==?= <pawel.sikora@agmk.net>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [3.6.11] NFS: Cache request denied due to non-unique superblock
 keys.
Date: Wed, 19 Dec 2012 19:35:50 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91196AB48@SACEXCMBX04-PRD.hq.netapp.com>
References: <6078496.RFsWrNWv86@localhost>
In-Reply-To: <6078496.RFsWrNWv86@localhost>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-12-19 at 19:58 +-0100, Pawe+AUI- Sikora wrote:
+AD4- Hi,
+AD4- 
+AD4- i'm testing the 3.6.11 kernel on some small internal nfs network (1 server +ADw--+AD4- 2 clients)
+AD4- and observing such info in dmesg on the client side. could you put some light on this dmesg entry?
+AD4- is it a bug or misconfiguration? i can provide more information about nfs configuration
+AD4- if necessary but denying caching doesn't look nicely.
+AD4- 
+AD4- i'm using following nfs related packages:
+AD4- 
+AD4- autofs-5.0.5-1.x86+AF8-64
+AD4- libnfsidmap-0.25-4.x86+AF8-64
+AD4- nfs-utils-1.2.7-1.x86+AF8-64
+AD4- nfs-utils-clients-1.2.7-1.x86+AF8-64
+AD4- nfs-utils-common-1.2.7-1.x86+AF8-64
+AD4- 
+AD4- BR,
+AD4- Pawe+AUI-.

It's hard to guess when you don't tell us anything about what you are
doing to trigger this message, but it sounds as if you are trying to use
the cachefs mount options incorrectly.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
