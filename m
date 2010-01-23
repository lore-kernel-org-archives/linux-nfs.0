Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932068Ab0AWOhb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jan 2010 09:37:31 -0500
Date: Sat, 23 Jan 2010 09:37:27 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Ray Van Dolson <rvandolson@esri.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Source address in server callbacks fix...
Message-ID: <20100123093727.274ad488@tlielax.poochiereds.net>
In-Reply-To: <20100122201638.GA26316@esri.com>
References: <20100122200525.GA26072@esri.com>
	<20100122201638.GA26316@esri.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 22 Jan 2010 12:16:38 -0800
Ray Van Dolson <rvandolson@esri.com> wrote:

> On Fri, Jan 22, 2010 at 12:05:25PM -0800, Ray Van Dolson wrote:
> > We're being bitten by the source address in server callbacks
> > issue[1][2].
> > 
> > The post above[1], mentions kernel fixes for this.  I'm having a hard
> > time locating this commit so I can determine if it has been backported
> > to the RHEL5 kernel yet.
> > 
> > Can anyone point me in the right direction?
> 
> Spoke too soon.  This[1] appears to be it.  Don't know if there are
> subsequent patches that improve upon this or not...
> 
> Ray
> 
> [1] http://git.linux-nfs.org/?p=bfields/linux.git;a=commit;h=16cefa8c3863721fd40445a1b34dea18cd16ccfe
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

This should be fixed in RHEL5.5:

https://bugzilla.redhat.com/show_bug.cgi?id=500653

-- 
Jeff Layton <jlayton@redhat.com>
