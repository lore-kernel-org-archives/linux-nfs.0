Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755743Ab2AKTpE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 14:45:04 -0500
Message-ID: <1326311086.26351.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH RESEND 0/9] pnfsblock patches for 3.3 post-rc1
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: Jim Rees <rees@umich.edu>, linuxnfs <linux-nfs@vger.kernel.org>,
        mdw@umich.edu, honey@citi.umich.edu
Date: Wed, 11 Jan 2012 14:44:46 -0500
In-Reply-To: <CA+a=Yy4uaQmR7Zyi3HO5=tF2XbBsKaSgG90_SN2GUWAnTsZVUQ@mail.gmail.com>
References: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
	 <20120110161406.GA8994@umich.edu>
	 <CA+a=Yy4uaQmR7Zyi3HO5=tF2XbBsKaSgG90_SN2GUWAnTsZVUQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-01-11 at 00:35 +0800, Peng Tao wrote: 
> On Wed, Jan 11, 2012 at 12:14 AM, Jim Rees <rees@umich.edu> wrote:
> > Peng Tao wrote:
> >
> >  These are pnfsblock patches rebased on top of nfs-for-3.3. All patches
> >  were sent to list before and merged by Benny.
> >
> > Once again, 8/9 and 9/9 failed to make it to the list.  Are these available
> > via git?
> sigh... vger seems always eating them... Thank you for pointing it out!
> 
> Trond, please find 8/9 and 9/9 in attachments. 2/9 was lost before so
> I also attached it here just in case. All patches are also available
> at
> git://github.com/bergwolf/linux.git for-trond-3.3
> which is based on top of nfs-for-3.3
> 

Please note that if you want patches to go into the stable stream, the
email address is now

Cc: stable@vger.kernel.org

instead of the old stable@kernel.org.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

