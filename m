Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620AbaKQTr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 14:47:58 -0500
Date: Mon, 17 Nov 2014 14:47:52 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
In-Reply-To: <3987E905-52A4-4F8E-AF97-FCAC0503260F@oracle.com>
Message-ID: <alpine.LRH.2.11.1411171443500.21288@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <3987E905-52A4-4F8E-AF97-FCAC0503260F@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 11 Nov 2014, Chuck Lever wrote:

>
> > On Nov 11, 2014, at 8:39 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > I will update mount.nfs so the default version is 4.1.
>
> Hi Ben, can you explicitly test your change with NFSv4.0-only servers? Thanks!

Hi Chuck,

I've posted a first-pass:
http://marc.info/?l=linux-nfs&m=141625339013956&w=2

I've tested against rpc.nfsd with '-N 4.1', and fallback to v4.0 seems
to work fine.

Ben
