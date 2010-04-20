From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] Four more pre-requisites for mountd IPv6 support
Date: Tue, 20 Apr 2010 08:16:20 -0400
Message-ID: <20100420081620.7b581fd8@tlielax.poochiereds.net>
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814Ab0DTMQZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 08:16:25 -0400
In-Reply-To: <20100419201855.3567.9644.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Apr 2010 16:20:51 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

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

These look good to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
