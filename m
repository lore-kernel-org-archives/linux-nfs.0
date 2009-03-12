From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 15:32:10 -0400
Message-ID: <20090312193210.GA7530@fieldses.org>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org> <49B93C10.5020208@disney.com> <20090312164818.GF2081@fieldses.org> <82886FA0-DF61-4979-B914-3CC59BAA2493@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33677 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757412AbZCLTcM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 15:32:12 -0400
In-Reply-To: <82886FA0-DF61-4979-B914-3CC59BAA2493@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 01:22:32PM -0400, Chuck Lever wrote:
> Actually I would rather see the performance metrics scripts improved.   
> These tools give a lot more information than nfsstat ever will be able  
> to.

Probably so, but those scripts are a bit hard to find, aren't they?

We should
	- get distributions to install them by default
	- write man pages?
	- add references to them where possible (from the nfsstat man
	  page, from howto's/faq's/?)

Until then, unfortunately, improvements to nfsstat are more useful,
since nfsstat is the thing people are more likely to run across.

(Which might be an argument just for adding their functionality into
nfsstat--that would have the one benefit that there'd be only one
command name users have to know about.)

--b.
