Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:46357 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753825Ab0H3QMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:12:07 -0400
Date: Mon, 30 Aug 2010 11:04:43 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
To: Kian Mohageri <kian.mohageri@gmail.com>
cc: davidr@ressman.org, linux-nfs@vger.kernel.org, cl@linux-foundation.com
Subject: Re: fsync/wb deadlocks in 2.6.32
In-Reply-To: <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1008301101560.10316@router.home>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com> <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com> <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 27 Aug 2010, Kian Mohageri wrote:

> Just happened upon this message.  My symptoms are a little different,
> however, and I'm still investigating the possibility of a faulty drive
> on the NFS server.... but thought I'd chime in anyway:

Its a bit troublesome that a faulty drive on an NFS server could cause
kernel backtraces to show up on the NFS client. The faulty NFS server
should also give you some indication that there are issues with the drive.
Does it?

Plus this is an async NFS configuration. Why does the NFS server fsync and
wait at all?
