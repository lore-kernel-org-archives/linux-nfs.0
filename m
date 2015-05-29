Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328AbbE2NoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2015 09:44:12 -0400
Date: Fri, 29 May 2015 09:44:11 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
In-Reply-To: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1505290942250.65323@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 May 2015, Olga Kornievskaia wrote:

> Hi folks,
>
> Problem:
> The upstream nfs4.0 client has problem where it will go into an
> infinite loop of re-sending an OPEN when it's trying to recover from
> receiving a BAD_STATEID error on an IO operation such READ or WRITE.
>
> How to easily reproduce (by using fault injection):
> 1. Do nfs4.0 mount to a server.
> 2. Open a file such that the server gives you a write delegation.
> 3. Do a write. Have a server return a BAD_STATEID. One way to do so is
> by using a python proxy, nfs4proxy, and inject BAD_STATEID error on
> WRITE.
> 4. And off it goes with the loop.

Hi Olga,

I've been trying to reproduce it, and I'm frustratingly unable.  It sounds
fairly easy to produce..  What version of the client produces this?

Ben
