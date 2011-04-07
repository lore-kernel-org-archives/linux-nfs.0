Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65416.mail.ac4.yahoo.com ([76.13.9.36]:27778 "HELO
	web65416.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751576Ab1DGOeZ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 10:34:25 -0400
Message-ID: <642211.9524.qm@web65416.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 07:34:22 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <56C8986A-3C8B-46C7-8C98-61C62FBC6BF8@oracle.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Thu, 4/7/11, Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 6, 2011, at 3:25 PM, Andrew Klaassen wrote:
> 
> > I have, for now, hacked my way around my problem by
> > splitting the server's uplink into two separate bonds. 
> > This seems to have moderated the transaction rate of the HPC
> > farm and allowed the "ls -l" calls to be served at an
> > acceptable rate.
> 
> Have you created enough nfsd threads on your Linux NFS
> servers?

That was one of the things I varied as part of my testing; almost every power of 2 from 8 threads up to 1024 threads.  It actually made things slightly worse, not better, but I can certainly give it a try again.

Andrew


