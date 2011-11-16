Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:46075 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751674Ab1KPXor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Nov 2011 18:44:47 -0500
Date: Wed, 16 Nov 2011 18:44:34 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: John Hughes <john@calvaedi.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111116234434.GA12882@umich.edu>
References: <4EC3FD8B.6000705@calvaedi.com>
 <20111116144718.78b2e288@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111116144718.78b2e288@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:

  Uhhh, no...EKEYEXPIRED was never passed to userland. The patchset that
  added EKEYEXPIRED returns in this codepath also added the code to make
  it hang. 
  
  This not a bug, or at least it's intentional behavior. When a krb5
  ticket expires, we *want* the process to hang. Otherwise, people with
  long running jobs will often find that their jobs error out
  inexplicably when their ticket expires.

Who decided that?  This seems completely wrong to me.  If my credentials
expire, I want to get permission denied, not a client hang.  In 20 years of
using authenticated file systems I never once wished my process had hung
when my ticket expired.

Why should this be any different from any other failure condition?  If you
try to open a file that doesn't exist, do you want your process to hang
instead of getting ENOENT, just in case the file magically appears at some
point in the future?

This seems a recipe for disaster.  Suppose I have a cron job that fires once
a minute, and all those jobs hang waiting for a ticket.  I come to work in
the morning and discover I've got 10,000 hung processes.  Or not, because my
computer has crashed from resource exhaustion.
