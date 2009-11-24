Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47460 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932760AbZKXUEc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:04:32 -0500
Date: Tue, 24 Nov 2009 15:04:35 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Charles Duffy <charles@dyfis.net>, linux-nfs@vger.kernel.org
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Message-ID: <20091124150435.58a11aef@tlielax.poochiereds.net>
In-Reply-To: <20091124150301.75060cfa@tlielax.poochiereds.net>
References: <hehc8g$k8f$1@ger.gmane.org>
	<20091124150301.75060cfa@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 24 Nov 2009 15:03:01 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 24 Nov 2009 13:26:44 -0600
> Charles Duffy <charles@dyfis.net> wrote:
> 
> > Howdy. With a very heavily loaded (CentOS 5 - Linux 2.6.18-128.el5) 
> > NFSv3 client and server, I've experienced the following sporadic issue:
> > 
> > function atomic_write() {
> >      local filename="$1"
> >      local tempfile
> >      tempfile="$(mktemp "${filename}.XXXXXX")"
> >      cat >"${tempfile}" && mv "${tempfile}" "${filename}"
> > }
> > 
> > $ atomic_write /mnt/foobar <<<"baz"
> > mv: cannot move `/mnt/foobar.gO1881' to `/mnt/foobar': No such file or 
> > directory
> > 
> > Are my assumptions regarding available semantics fair and reasonable?
> > 
> 
> Known problem with O_EXCL creates. Fixed in RHEL fairly recently. You
> probably want a newer kernel.
> 

My mistake...I didn't read the version closely enough. I was thinking
of another issue. I'm not sure if a newer kernel will help you.

-- 
Jeff Layton <jlayton@redhat.com>
