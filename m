Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24449 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755728Ab1I2UMA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 16:12:00 -0400
Date: Thu, 29 Sep 2011 16:11:56 -0400
From: Dave Jones <davej@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.1rc7+ FSX failure over NFS
Message-ID: <20110929201155.GA1143@redhat.com>
References: <20110929184127.GA12236@redhat.com>
 <1317322772.8708.30.camel@lade.trondhjem.org>
 <20110929190519.GA15165@redhat.com>
 <1317324133.8708.43.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317324133.8708.43.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 29, 2011 at 03:22:13PM -0400, Trond Myklebust wrote:
 > On Thu, 2011-09-29 at 15:05 -0400, Dave Jones wrote: 
 > > On Thu, Sep 29, 2011 at 02:59:32PM -0400, Trond Myklebust wrote:
 > >  
 > >  > 1) What filesystem are you using on the server, and does that filesystem
 > >  > support high resolution timestamps?
 > > 
 > > ext3
 > 
 > Hmm... Is the problem also reproducible with ext4 or xfs?
 
I have an ext4 mount on the same machine. It's been running an hour now without
problem, so I assume it's ok.

	Dave

