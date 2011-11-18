Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:42384 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755448Ab1KRBv1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 20:51:27 -0500
Date: Thu, 17 Nov 2011 20:51:16 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: John Hughes <john@Calva.COM>, Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111118015116.GA1959@umich.edu>
References: <4EC3FD8B.6000705@calvaedi.com>
 <20111116144718.78b2e288@corrin.poochiereds.net>
 <20111116234434.GA12882@umich.edu>
 <20111116203119.1d9c0dd6@corrin.poochiereds.net>
 <20111116203810.4e1b9d28@corrin.poochiereds.net>
 <4EC4EA91.5070607@Calva.COM>
 <4EC50882.2080803@Calva.COM>
 <20111117164630.394027e7@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111117164630.394027e7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I would argue that if you don't want your applications to stop working when
your ticket expires, you shouldn't let the ticket expire.  If you don't want
to have to renew your ticket, you should use an infinite ticket lifetime.

It sounds like you've made up your mind, but I would urge you to make this
a mount option, analogous to the hard/soft mount option.
