Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:55332 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964962AbbCSR1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 13:27:34 -0400
Date: Thu, 19 Mar 2015 18:27:31 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150319172731.GA16329@lst.de>
References: <20150304224557.GY4251@dastard> <54F78BE5.1020608@sandeen.net> <20150304225623.GZ4251@dastard> <20150305040849.GJ1627@fieldses.org> <20150305131731.GA16235@lst.de> <20150305150138.GA15674@fieldses.org> <20150305170217.GC15674@fieldses.org> <20150305204749.GA17934@fieldses.org> <20150305205922.GF18360@dastard> <20150306204715.GA27257@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150306204715.GA27257@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I've now managed to reproduce the issue.  I haven't had time
to dig deeper, but it smells a lot like a callback path issue.

Can you send the recursion fix to Linus ASAP and I'll send you a patch
to turn the nopnfs option into a pnfs one, so we're at least doing
fine for 4.0 in any case.  I hope to debug this and may even have
a real fix soon, but so far I don't know how long it will take.
