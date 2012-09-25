Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17052 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755861Ab2IYUwj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2012 16:52:39 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>, Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Any way to allow setuid daemon to access krb5 automounted nfs
 directories?
Date: Tue, 25 Sep 2012 20:52:36 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FE99CE@SACEXCMBX04-PRD.hq.netapp.com>
References: <5061DF69.8030606@cora.nwra.com>
 <20120925175025.GA8020@umich.edu>
In-Reply-To: <20120925175025.GA8020@umich.edu>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Jim Rees
> Sent: Tuesday, September 25, 2012 1:50 PM
> To: Orion Poplawski
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Any way to allow setuid daemon to access krb5 automounted
> nfs directories?
>
> But I hope you're not planning to deliver mail over nfs. I think that would be a
> mistake.

What's wrong with that? Delivering and serving up email is a fairly common use-case for NFS.

Trond
