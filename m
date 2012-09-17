Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325Ab2IQQFM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2012 12:05:12 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: readdir cookies
Date: Mon, 17 Sep 2012 16:05:10 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FC8D4C@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120917155426.GK30673@fieldses.org>
In-Reply-To: <20120917155426.GK30673@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, September 17, 2012 11:54 AM
> To: Myklebust, Trond; Schumaker, Bryan
> Cc: linux-nfs@vger.kernel.org
> Subject: readdir cookies
> 
> How does the nfs client decide what directory cookies to return?  (As the
> d_off field to readdir, for example).
> 
> I'd assumed it would return the server's cookie, but testing shows it returns a
> simple integer sequence.

We cache the cookies and use them to figure out where the readdir cursor is after a directory update, but we use positive integers for telldir()/seekdir(). The reason is that too many servers return cookies that use > 32 bits (NFSv2-incompatible) or are unsigned.

Cheers
  Trond
