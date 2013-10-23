Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab3JWN62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Oct 2013 09:58:28 -0400
Message-ID: <5267D630.4030909@RedHat.com>
Date: Wed, 23 Oct 2013 09:59:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] mountd: Deprecate the ability to disable TCP listeners.
References: <1382429966-14531-1-git-send-email-steved@redhat.com> <1382429966-14531-3-git-send-email-steved@redhat.com> <20131022113940.GA15951@umich.edu>
In-Reply-To: <20131022113940.GA15951@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/10/13 07:39, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   -"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
>   +"	[-N version|--no-nfs-version version] [-n|--no-tcp(deprecate)]\n"
> 
> I would take this out.
> 
Take out the word "deprecate" or the "[-n|--no-tcp(deprecate)]" flag?

steved.
