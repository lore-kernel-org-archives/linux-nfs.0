From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: Re: (ANSWER) Question About nfs3 vs. nfs4 Semantics On Sun 7310	Server
Date: Thu, 05 Nov 2009 13:32:37 -0800
Message-ID: <4AF34475.4000906@berkeley.edu>
References: <hcsvs6$dbl$1@ger.gmane.org> <20091105195515.GA1989@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out1.Berkeley.EDU ([128.32.61.106]:27812 "EHLO
	smtp-out1.berkeley.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758509AbZKEVuf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 16:50:35 -0500
In-Reply-To: <20091105195515.GA1989@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

> I still don't understand quite what was happening: in the absence of
> "noacl", does the client just always claim to support the posix acl
> xattr's, but return an error when cp attempts to set them?

I didn't monitor the wire so I can only guess.
My guess is 'yes'. However, given that the client
also falsely that it couldn't preserve permissions
I'm not sure what's really going on.

-- 
Jon Forrest
Research Computing Support
College of Chemistry
173 Tan Hall
University of California Berkeley
Berkeley, CA
94720-1460
510-643-1032
jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org
