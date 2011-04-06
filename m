Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65410.mail.ac4.yahoo.com ([76.13.9.30]:43797 "HELO
	web65410.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756616Ab1DFTZY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 15:25:24 -0400
Message-ID: <747262.60831.qm@web65410.mail.ac4.yahoo.com>
Date: Wed, 6 Apr 2011 12:25:21 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>
Cc: Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <526840.20197.qm@web65402.mail.ac4.yahoo.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have, for now, hacked my way around my problem by splitting the server's uplink into two separate bonds.  This seems to have moderated the transaction rate of the HPC farm and allowed the "ls -l" calls to be served at an acceptable rate.

If someone smart thinks that giving the problem a real solution would be worthwhile, I'd be glad to offer more details about my test setup.

Thanks again for the various suggestions offered.

Andrew


--- On Tue, 4/5/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:

> From: Andrew Klaassen <clawsoon@yahoo.com>
> Subject: Re: Prioritizing readdirplus/getattr/lookup
> To: "Benny Halevy" <bhalevy@panasas.com>, "Jim Rees" <rees@umich.edu>
> Cc: "Garth Gibson" <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
> Received: Tuesday, April 5, 2011, 5:06 PM
> --- On Tue, 4/5/11, Jim Rees <rees@umich.edu>
> wrote:
> 
> > It would be interesting to see someone who is affected
> by
> > this implement the readdirplus system call, modify ls
> to
> > use it, and report the results.  I suspect the system
> call
> > won't go anywhere in linux without some evidence
> > that it solves a real problem for real users.
> 
> I can't speak to a readdirplus system call; my own
> (admittedly naive) testing suggests that the system calls
> are JustFineThankYou, since local "ls -l" with NFS loading
> (and vice versa) performs very well.
> 
> What I can say for certain is that whatever NetApp GX is
> doing to respond to getattr and lookup calls completely
> wipes the floor with whatever the Linux nfsd is doing...
> 
> ...*even when Linux is serving out a completely cached,
> completely read-only workload*.
> 
> I wish I had the know-how and intelligence to figure out
> exactly why.
> 
> Andrew
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
