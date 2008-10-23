From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: why set send and receive buffers in svc_sock_setbufsize()?
Date: Thu, 23 Oct 2008 14:53:13 -0400
Message-ID: <20081023185313.GB25666@fieldses.org>
References: <20081023144844.610e294d@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, smfrench@gmail.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378AbYJWSxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 14:53:14 -0400
In-Reply-To: <20081023144844.610e294d-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2008 at 02:48:44PM -0400, Jeff Layton wrote:
> I've been reviewing a patch for CIFS, and out of the discussions over
> that patch, there's been the recommendation to not set sk_sndbuf and
> sk_rcvbuf. Apparently, setting these to a value will place a hard limit
> on the buffer sizes for the socket, so there's not much need to set
> these unless we want to limit memory usage to this value for some
> reason.
> 
> One question is that the sunrpc code sets these values in
> svc_sock_setbufsize(). What is the reasoning behind this?
> 
> If we're doing it to limit memory consumption then that's certainly
> valid, but if we're doing this to attempt to make sure that we have
> "enough" buffer space for the expected load then this may be
> counter-productive.

Yep!  See

	http://marc.info/?l=linux-nfs&m=122461390600382&w=2

and followups; Olga and Jim have found this makes a huge difference to
performance on fast high-latency networks.

--b.
