Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59363 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368Ab1KRMuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 07:50:22 -0500
Date: Fri, 18 Nov 2011 07:50:10 -0500
From: Jim Rees <rees@umich.edu>
To: John Hughes <john@Calva.COM>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111118125010.GA2878@umich.edu>
References: <4EC3FD8B.6000705@calvaedi.com>
 <20111116144718.78b2e288@corrin.poochiereds.net>
 <20111116234434.GA12882@umich.edu>
 <20111116203119.1d9c0dd6@corrin.poochiereds.net>
 <20111116203810.4e1b9d28@corrin.poochiereds.net>
 <4EC4EA91.5070607@Calva.COM>
 <4EC50882.2080803@Calva.COM>
 <20111117164630.394027e7@tlielax.poochiereds.net>
 <4EC62325.1060009@Calva.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC62325.1060009@Calva.COM>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not arguing that the client machine should hang when tickets expire.
I'm arguing that user processes should not hang when tickets expire.  Sorry
if that wasn't clear.
