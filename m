Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e5.ny.us.ibm.com ([32.97.182.145]:40134 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758328Ab2HUSEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 14:04:12 -0400
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 21 Aug 2012 14:04:07 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 14D7C6E805D
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 14:03:57 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7LI3uSx057316
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 14:03:56 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7LI3tvk019269
	for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 15:03:56 -0300
Date: Tue, 21 Aug 2012 13:03:53 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Jim Rees <rees@umich.edu>
Cc: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Message-ID: <20120821180353.GB4561@us.ibm.com>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
 <20120821125905.GA16550@umich.edu>
 <k10bib$1fi$1@ultimate100.geggus.net>
 <20120821170759.GA13076@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821170759.GA13076@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Sven Geggus wrote:
> 
>   Jim Rees <rees@umich.edu> wrote:
>   
>   > No, the question is why did X put that file in your home directory.  That's
>   > not where it belongs.  I've got this in my .xinitrc:
>   > 
>   > setenv XAUTHORITY /tmp/Xauthority`id -u`
>   
>   I agree, that ~/.Xauthority is probably not the best place for this file,
>   but it is the default (at least in Debian).
>   
>   If it is expected behaviour that this will not work correctly with shared
>   Homedirectories, I wonder why this did not cause me any trouble with NFS3
>   for many years.

NFS3 doesn't have delegations and this file placement should not be an
issue in NFSv4 either if it is working correctly!

Regards, Malahal.

