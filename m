From: Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [NLM] 2.6.27 broken
Date: Tue, 16 Dec 2008 20:43:52 +0100
Message-ID: <1229456632.6023.1.camel@tucsk>
References: <20081115132831.GA11329@janus>
	 <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus>
	 <20081216173923.GE16388@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49452 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754855AbYLPTnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 14:43:52 -0500
In-Reply-To: <20081216173923.GE16388@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-12-16 at 12:39 -0500, J. Bruce Fields wrote:
> More precisely, it looks like this started with
> 
> 	bde74e4bc64415b142e "locks: add special return value for
> 		asynchronous locks"
> 
> But I haven't had the chance to look any harder yet.  Miklos?  Is this
> easy for you to reproduce?

Not immediately, at the moment I don't have NFS set up.  But if you
don't beat me to it, I'll look into this.

Thanks,
Miklos


