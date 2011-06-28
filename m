Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:55548 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758521Ab1F1RAz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 13:00:55 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5SGtd4Z017075
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 02:55:39 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5SGxSTN1298658
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 02:59:28 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5SH0jiC023452
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2011 03:00:45 +1000
Date: Tue, 28 Jun 2011 22:29:54 +0530
From: Prem Karat <prem.karat@linux.vnet.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
Message-ID: <20110628165954.GA13059@d6fc318.ibm.com>
References: <20110628104138.GB6600@d6fc318.ibm.com>
 <FA506314-750E-4E20-B80C-B507D032D962@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <FA506314-750E-4E20-B80C-B507D032D962@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/28/11 12:02pm, Chuck Lever wrote:
> 
> On Jun 28, 2011, at 6:41 AM, Prem Karat wrote:
> 
> > 
> > Currently souce and destination parameters should be passed as first and 
> > second paramter while using mount.nfs. This patch allows them to be passed 
> > anywhere while mounting.
> > 
> > Current functionality is
> > 	mount.nfs source destn -o <options>
> > This patch will allow to do this
> > 	mount.nfs -o <options> source destn
> > 		or
> > 	mount.nfs -o <options> source -o <options> destn
> 
> Yep, that's clear, but why is this desirable?  mount.nfs should be invoked only by the mount command.  It's not meant to be run by humans.
Bare with me if my understanding is incorrect, however the man page does say that
it can be used as a standalone command with limited functionality.

Also it makes sense to use it if a newbie wants to know the nfs specific
options. The mount.nfs command shows a pointer to the correct man page for
nfs specific options.

Cheers,
Prem
