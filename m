From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Re: Bug in server's export -- List of security flavors
Date: Thu, 16 Jul 2009 15:13:52 -0500
Message-ID: <4A5F8A00.8000104@excfb.com>
References: <4A5F5C4C.3070308@excfb.com> <20090716185642.GB2495@fieldses.org> <4A5F7EA9.9050309@excfb.com> <20090716194546.GG2495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao102.cox.net ([68.230.240.8]:38270 "EHLO
	eastrmmtao102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933193AbZGPUOD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2009 16:14:03 -0400
In-Reply-To: <20090716194546.GG2495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

support/nfs/exports.c

505                 if (strcmp(opt, "ro") == 0)
506                         setflags(NFSEXP_READONLY, active, ep);
507                 else if (strcmp(opt, "rw") == 0)
508                         clearflags(NFSEXP_READONLY, active, ep);
...
624                 } else if (strncmp(opt, "sec=", 4) == 0) {
625                         active = parse_flavors(opt+4, ep);

If you find a 'sec=' you go ahead and set it in the e_secinfo array.

But if you encounter a rw or ro before you encounter a 'sec=', you do
not set a flavor in the e_secinfo array.

What we do is if we encounter the 'rw' or 'ro' before the 'sec=', then
it defaults to being a AUTH_SYS flavor. If we encounter it after, then
we know which flavor to set it as.

Of course, we have to account for what happens if we have the following:
share -F nfs -o rw,sec=sys,ro /foo

Because we can't have both a rw and ro export.

