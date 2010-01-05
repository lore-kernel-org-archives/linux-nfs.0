From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/3] nfs-utils: add initial tests for statd that run via
 "make check"
Date: Tue, 5 Jan 2010 13:25:19 -0500
Message-ID: <20100105132519.02c3c76d@tlielax.poochiereds.net>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
	<1262706035-4929-4-git-send-email-jlayton@redhat.com>
	<4B436AD3.2080107@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126Ab0AESZZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 13:25:25 -0500
In-Reply-To: <4B436AD3.2080107-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 05 Jan 2010 11:37:39 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> > +export PATH=$PATH:$srcdir/nsm_client
> How or Where is '$srcdir' set??
> 

In the Makefile. Automake sets that along with other variables like
$top_srcdir. make then stuffs those variables into the environment when
it forks.

-- 
Jeff Layton <jlayton@redhat.com>
