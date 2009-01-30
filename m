From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6
	support is built in
Date: Fri, 30 Jan 2009 17:02:58 -0500
Message-ID: <20090130220258.GM31166@fieldses.org>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org> <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com> <1233350290.9741.42.camel@heimdal.trondhjem.org> <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com> <20090130215552.GI31166@fieldses.org> <B9230E38-9FCD-421C-84BE-E29A4D09B536@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38753 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755315AbZA3WC7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 17:02:59 -0500
In-Reply-To: <B9230E38-9FCD-421C-84BE-E29A4D09B536@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 30, 2009 at 05:01:36PM -0500, Chuck Lever wrote:
> On Jan 30, 2009, at Jan 30, 2009, 4:55 PM, J. Bruce Fields wrote:
>> On Fri, Jan 30, 2009 at 04:30:10PM -0500, Chuck Lever wrote:
>>> Also, having a separate IPv6-only listener means that someone can
>>> come along and hijack the IPv4 packets on that port.
>>
>> Starting listeners on both as early as possible reduces but doesn't
>> eliminate the chance of that happening.  Don't we just have to assume
>> users of low port numbers are well-behaved to some degree?
>
> We have one listener now, so it doesn't ever happen.

If you restart nfsd, or if other programs are running during boot, then
it can still happen.  Right?

--b.
