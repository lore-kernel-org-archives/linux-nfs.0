From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 05/29] knfsd: Infrastructure for providing stats to
	userspace
Date: Wed, 1 Apr 2009 14:43:45 +1100
Message-ID: <ac442c870903312043p46302b5t2e45d52c75f78e36@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202939.751001000@sgi.com>
	 <20090401002803.GD26583@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Banks <gnb@sgi.com>, Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:28806 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZDADnr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 23:43:47 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3373582rvb.1
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2009 20:43:45 -0700 (PDT)
In-Reply-To: <20090401002803.GD26583@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 1, 2009 at 11:28 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 07:28:05AM +1100, Greg Banks wrote:

>> The special "nm" keyword starts a new entry and shows it's internal
>> name, e.g. "nm 192.168.67.45" in the per-client statistics file will
>> begin the entry for the client whose IP address is 192.168.67.45.
>
> OK, so the rules for a userland script are that they should ignore any
> line which starts with a two-character code that they don't recognize,
> allowing us to add more of those later if necessary?

Yes, just like the existing /proc/net/rpc/nfsd (except that in both
cases it's really the first whitespace-separated word and that only
happens to be 2 chars long in most cases).

I expect to be documenting the format properly sometime later.  Also,
SGI has some software that reads the two new files and provides
metrics for the PCP (Performance Co-Pilot) monitoring package; I have
permission to release that as open source and expect to do so in the
next few days..

> I've also occasionally wanted something to expose per-client
> troubleshooting information of various sorts.  (For example: are
> callbacks to a given v4.0 client currently working, and if not, why
> not?)  So it'd be interesting if it could also be extended to do that
> sort of thing.

Sure.  This would be the ideal infrastructure for adding such counters.

-- 
Greg.
