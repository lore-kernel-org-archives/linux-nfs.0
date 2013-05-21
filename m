Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab3EUTuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 15:50:23 -0400
Date: Tue, 21 May 2013 12:50:20 -0700
From: Zach Brown <zab@redhat.com>
To: Eric Wong <normalperson@yhbt.net>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 1/4] vfs: add copy_range syscall and vfs entry point
Message-ID: <20130521195020.GC14767@lenny.home.zabbo.net>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <1368566126-17610-2-git-send-email-zab@redhat.com>
 <20130515194405.GA28720@dcvr.yhbt.net>
 <20130515200307.GD318@lenny.home.zabbo.net>
 <20130521194719.GA2957@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130521194719.GA2957@dcvr.yhbt.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 21, 2013 at 07:47:19PM +0000, Eric Wong wrote:
> Zach Brown <zab@redhat.com> wrote:
> > On Wed, May 15, 2013 at 07:44:05PM +0000, Eric Wong wrote:
> > > Why introduce a new syscall instead of extending sys_splice?
> > 
> > Personally, I think it's ugly to have different operations use the same
> > syscall just because their arguments match.
> 
> Fair enough.  I think adding a (currently unused) flags parameter would
> make sense for future-proofing.

Yeah, that seems reasonble.  

- z
