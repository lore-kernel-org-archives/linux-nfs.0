Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65404.mail.ac4.yahoo.com ([76.13.9.24]:33094 "HELO
	web65404.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757264Ab1DHBWj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 21:22:39 -0400
Message-ID: <437962.44516.qm@web65404.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 18:22:37 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: RE: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>,
        DennisMurata <DENNIS.MURATA@saic.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <620E93B2E5CC3B46BD811165E3335B870B8B0E09@0461-its-exmb02.us.saic.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Thu, 4/7/11, Murata, Dennis <DENNIS.MURATA@saic.com> wrote:

> Did you set each ksoftirqd to a
> specific cpu?
> Wayne 

I didn't do that explicitly, but /proc/interrupts shows that each CPU is handling the interrupts for only one ethernet card, so I assume that must be default behaviour.

Andrew



