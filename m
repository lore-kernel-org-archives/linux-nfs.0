From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH] NFS mount hang fix
Date: Wed, 27 Oct 2004 14:15:44 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041027121543.GH4724@fi.muni.cz>
References: <20041026141148.GM6408@fi.muni.cz> <20041026150640.GA24881@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au,
	torvalds@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262403AbUJ0MRo@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041026150640.GA24881@fieldses.org>
List-ID: <nfs.lists.sourceforge.net>

J. Bruce Fields wrote:
: Changing those buffers to static strikes me as potentially dangerous--we
: currently call the ->parse() methods under a semaphore, so it's safe for
: now, but that might change some day and then there'll be an ugly race
: condition.
: 
: Could you check whether the following fixes your problem?--b.
: 
	Yes, it is OK with this patch. Thanks,

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <
