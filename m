From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 15:03:01 -0500
Message-ID: <20091124150301.75060cfa@tlielax.poochiereds.net>
References: <hehc8g$k8f$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757320AbZKXUC6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:02:58 -0500
In-Reply-To: <hehc8g$k8f$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Nov 2009 13:26:44 -0600
Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org> wrote:

> Howdy. With a very heavily loaded (CentOS 5 - Linux 2.6.18-128.el5) 
> NFSv3 client and server, I've experienced the following sporadic issue:
> 
> function atomic_write() {
>      local filename="$1"
>      local tempfile
>      tempfile="$(mktemp "${filename}.XXXXXX")"
>      cat >"${tempfile}" && mv "${tempfile}" "${filename}"
> }
> 
> $ atomic_write /mnt/foobar <<<"baz"
> mv: cannot move `/mnt/foobar.gO1881' to `/mnt/foobar': No such file or 
> directory
> 
> Are my assumptions regarding available semantics fair and reasonable?
> 

Known problem with O_EXCL creates. Fixed in RHEL fairly recently. You
probably want a newer kernel.

-- 
Jeff Layton <jlayton@redhat.com>
