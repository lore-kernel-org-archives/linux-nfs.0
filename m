From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 15:18:26 -0400
Message-ID: <20090416191826.GC1145@fieldses.org>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com> <20090416182313.GE450@fieldses.org> <49E7809B.2020002@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42045 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbZDPTS3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 15:18:29 -0400
In-Reply-To: <49E7809B.2020002-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 16, 2009 at 03:01:47PM -0400, Steve Dickson wrote:
> I do get your point, but as we did with the initial v4 support, 
> having the support on by default and then having away to turn it
> off is the correct approach... IMHO... 

I'd prefer it be off by default, for the obvious safety reasons.  (It's
under rapid development and particularly likely to have bugs).  The only
reason we had it on by default before was that we didn't add the
switching mechanism early enough.  (Well, and because we could keep it
off in the config.  But I'd rather be able to ship users a kernel that
supports 4.1 and give them the option of turning it on at runtime, than
make them build a new kernel.)

--b.
