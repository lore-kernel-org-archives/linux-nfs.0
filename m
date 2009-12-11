Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46166 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756844AbZLKSBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 13:01:53 -0500
Subject: Re: starting 90-second grace period
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
	 <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
	 <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Dec 2009 13:01:55 -0500
Message-Id: <1260554515.15701.0.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-12-11 at 22:55 +0530, Tharindu Rukshan Bamunuarachchi
wrote: 
> thankx a lot for the info.
> 
> btw, if i set nfs4leasetime to ~10 seconds ... is there any negative effect ?
> 

You mean aside from the very likely event that your clients will lose
all their locks when the server reboots?

Trond

