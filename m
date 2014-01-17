Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbaAQLyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 06:54:32 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0HBsVEX012133
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 06:54:31 -0500
Date: Fri, 17 Jan 2014 06:54:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Simo Sorce <simo@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] Fix credential sourcing with new setuid behavior in
 rpc.gssd
Message-ID: <20140117065430.1d034e4a@tlielax.poochiereds.net>
In-Reply-To: <1389931919-4801-1-git-send-email-simo@redhat.com>
References: <20140116204949.1bea663a@corrin.poochiereds.net>
	<1389931919-4801-1-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 16 Jan 2014 23:11:57 -0500
Simo Sorce <simo@redhat.com> wrote:

> Take 2
> 
> Patch 1: simply remove the old code that is not necessary anymore
> 
> Bonus patch 2: clean up code, name is not needed anymore as the default
> credentials for the impersonated uid are always used.
> 
> Simo Sorce (2):
>   Improve first attempt at acquiring GSS credentials
>   Remove unused parameter
> 
>  utils/gssd/krb5_util.c |   28 ++++------------------------
>  1 files changed, 4 insertions(+), 24 deletions(-)
> 

LGTM

Acked-by: Jeff Layton <jlayton@redhat.com>
