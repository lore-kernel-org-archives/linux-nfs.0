From: Peter Staubach <staubach@redhat.com>
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 15:03:04 -0500
Message-ID: <4B0C3BF8.1070904@redhat.com>
References: <hehc8g$k8f$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757601AbZKXUDA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:03:00 -0500
In-Reply-To: <hehc8g$k8f$1@ger.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Charles Duffy wrote:
> Howdy. With a very heavily loaded (CentOS 5 - Linux 2.6.18-128.el5)
> NFSv3 client and server, I've experienced the following sporadic issue:
> 
> function atomic_write() {
>     local filename="$1"
>     local tempfile
>     tempfile="$(mktemp "${filename}.XXXXXX")"
>     cat >"${tempfile}" && mv "${tempfile}" "${filename}"
> }
> 
> $ atomic_write /mnt/foobar <<<"baz"
> mv: cannot move `/mnt/foobar.gO1881' to `/mnt/foobar': No such file or
> directory
> 
> Are my assumptions regarding available semantics fair and reasonable?
> 

At the end, does /mnt/foobar exist and contain the string, "baz"?

What mount options are being used on the client?

It sounds to me as if the duplicate request cache on the server
is not working, perhaps because entries are being recycled too
quickly, and does not catch a retransmitted RENAME operation.

	Thanx...

		ps
