Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758590Ab0J1Nih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 09:38:37 -0400
Date: Thu, 28 Oct 2010 09:38:33 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: fix default value for --enable-tirpc
Message-ID: <20101028093833.6541ce21@tlielax.poochiereds.net>
In-Reply-To: <4CC97970.6010706@RedHat.com>
References: <1286846991-4876-1-git-send-email-jlayton@redhat.com>
	<4CC97970.6010706@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 28 Oct 2010 09:24:00 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> Jeff,
> 
> On 10/11/2010 09:29 PM, Jeff Layton wrote:
> > The patch I originally proposed to make --enable-tirpc the default had
> > the default for $enable_tirpc as a blank string. When it was merged
> > however, that value was changed to a 'yes'. 
> Which commit or proposal are you talking about? I'm looking at commit 148503a
> which changed it for no to yes, but I can not seem to find the 
> proposal you are talking about?
> 
> I'm just trying to figure how the merge broke it so it does
> not happen again... 
> 
> steved.
> 

Here was the original patch posting:

http://www.spinics.net/lists/linux-nfs/msg07718.html

I checked my mail archives and didn't see emails where we discussed
this patch specifically around that time. Maybe we did on IRC before
you merged it and I misunderstood what you intended to change? Hard to
remember since it was over a year ago...

-- 
Jeff Layton <jlayton@redhat.com>
