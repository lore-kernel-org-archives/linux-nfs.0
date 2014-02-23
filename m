Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:43518 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbaBWSEP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Feb 2014 13:04:15 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 943752802EC
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 19:04:13 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8909713E9C
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 19:04:12 +0100 (MET)
Date: Sun, 23 Feb 2014 19:04:09 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1981701027.186711.1393178649862.JavaMail.zimbra@desy.de>
In-Reply-To: <94863747-3B23-4534-8990-F04F0C8D54DE@gmail.com>
References: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de> <94863747-3B23-4534-8990-F04F0C8D54DE@gmail.com>
Subject: Re:
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Trond Myklebust" <trondmy@gmail.com>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Sent: Sunday, February 23, 2014 5:41:26 PM
> Subject: Re:
> 
> 
> On Feb 23, 2014, at 11:22, tigran.mkrtchyan@desy.de wrote:
> 
> > to me it's unclear, why a SETATTR  always follows an OPEN, even in case of
> > EXCLUSIVE4_1. With this fix, I get desired behavior.
> 
> Yes, but that fix risks incurring an NFS4ERR_INVAL from which we cannot
> recover because it does not include the mandatory check for the allowed set
> of attributes.
> Please see RFC5661 section 18.16.3 about the client side use of
> ‘suppattr_exclcreat’ .

Yes, I noticed, that client never query that attribute. I will check a
possibility to add a check for suppattr_exclcreat as well.

Tigran.

> 
> Cheers,
>   Trond
