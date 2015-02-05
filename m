Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:38560 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbbBEHba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Feb 2015 02:31:30 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 9E629280207
	for <linux-nfs@vger.kernel.org>; Thu,  5 Feb 2015 08:31:28 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 9139B13E8E
	for <linux-nfs@vger.kernel.org>; Thu,  5 Feb 2015 08:31:28 +0100 (MET)
Date: Thu, 5 Feb 2015 08:31:27 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: dE <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1196552310.744640.1423121487541.JavaMail.zimbra@desy.de>
In-Reply-To: <54D237A5.1050302@gmail.com>
References: <54D237A5.1050302@gmail.com>
Subject: Re: Cant get to export this particular directory.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


are you sure that your clients mount with ipv6 (as your export ipv6 only)?

Tigran.

----- Original Message -----
> From: "dE" <de.techno@gmail.com>
> To: linux-nfs@vger.kernel.org
> Sent: Wednesday, February 4, 2015 4:15:49 PM
> Subject: Cant get to export this particular directory.

> Hi.
> 
> I'm trying to export a particular directory with these parameters --
> 
> /home/test/huge/temp_small/subdir
> fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)
> 
> For all subdirectories in temp_small, the client fails to mount saying
> permission denied.
> 
> mount.nfs: access denied by server while mounting.....
> 
> For any other place it works.
> 
> And because rpc.mountd has no logging features, I got no idea what's
> happening.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
