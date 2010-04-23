Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758459Ab0DWRQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 13:16:07 -0400
Message-ID: <4BD1CAFC.9080200@RedHat.com>
Date: Fri, 23 Apr 2010 12:29:48 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] Four more pre-requisites for mountd IPv6 support
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
In-Reply-To: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 04/19/2010 04:20 PM, Chuck Lever wrote:
> Hi Steve-
> 
> These patches clean up some memory allocation nits in libexport.a.
> They pave the way for parsing IPv6 addresses and netmasks in
> client_init().
> 
> ---
> 
> Chuck Lever (4):
>       libexport.a: Allow malloc(3) failures in client_lookup() and friends
>       libexport.a: Allow m_hostname allocation to fail instead of exit
>       libexport.a: Allow client_init() to fail instead of exit
>       libexport.a: Add client_free()
> 
> 
>  support/export/client.c |   55 +++++++++++++++++++++++++++++++----------------
>  1 files changed, 36 insertions(+), 19 deletions(-)
> 
All four committed... 

steved.
