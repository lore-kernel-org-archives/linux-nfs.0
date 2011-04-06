Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65402.mail.ac4.yahoo.com ([76.13.9.22]:45080 "HELO
	web65402.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751941Ab1DFAGs convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Apr 2011 20:06:48 -0400
Message-ID: <526840.20197.qm@web65402.mail.ac4.yahoo.com>
Date: Tue, 5 Apr 2011 17:06:46 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>
Cc: Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <20110405193425.GA4263@merit.edu>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Tue, 4/5/11, Jim Rees <rees@umich.edu> wrote:

> It would be interesting to see someone who is affected by
> this implement the readdirplus system call, modify ls to
> use it, and report the results.  I suspect the system call
> won't go anywhere in linux without some evidence
> that it solves a real problem for real users.

I can't speak to a readdirplus system call; my own (admittedly naive) testing suggests that the system calls are JustFineThankYou, since local "ls -l" with NFS loading (and vice versa) performs very well.

What I can say for certain is that whatever NetApp GX is doing to respond to getattr and lookup calls completely wipes the floor with whatever the Linux nfsd is doing...

...*even when Linux is serving out a completely cached, completely read-only workload*.

I wish I had the know-how and intelligence to figure out exactly why.

Andrew


