From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug#492970: (was: nfs-utils-1.1.3 released)
Date: Sun, 10 Aug 2008 17:40:53 -0400
Message-ID: <20080810214053.GE30411@fieldses.org>
References: <87myjul1fk.fsf@burly.wgtn.ondioline.org> <20080803151022.GA31484@fieldses.org> <60C652E1-512E-484A-874E-01997B688505@oracle.com> <87d4ko5wlx.fsf@burly.wgtn.ondioline.org> <9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com> <863alj9s8p.fsf@gere.msconsult.dk> <5535F9D8-CD96-4807-80B3-7FD4B3983794@oracle.com> <20080807150514.GA3696@xanadu.blop.info> <6A0B8017-9FCB-4CF1-88F0-8E5752AC22EC@oracle.com> <2237EBE9-FE80-4B9A-B908-1533C47BBD0F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	bcwong-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37795 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbYHJVk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Aug 2008 17:40:56 -0400
In-Reply-To: <2237EBE9-FE80-4B9A-B908-1533C47BBD0F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 08, 2008 at 09:06:46PM -0400, Chuck Lever wrote:
> Confirmed.  The kernel's mountd client doesn't even bother to  
> unmarshal the auth flavor list in the server's reply.
> 
> I'll work on a fix.

By the way, the server side is also kinda dumb here--it just returns a
fixed status list regardless of what security is set on the export.
This isn't hard to fix--I'm just debugging some patches.

--b.
