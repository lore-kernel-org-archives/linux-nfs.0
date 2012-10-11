Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29438 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776Ab2JKSTg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 14:19:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andy Adamson <androsadamson@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH] NFSv4.1: Kill nfs4_ds_disconnect()
Date: Thu, 11 Oct 2012 18:19:32 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9091E85D5@SACEXCMBX04-PRD.hq.netapp.com>
References: <1349974296-48449-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAHVgHyVnowveZDOp8X_YC1K9Y7WOmj6A-TU_doDgV78vGm-cYQ@mail.gmail.com>
In-Reply-To: <CAHVgHyVnowveZDOp8X_YC1K9Y7WOmj6A-TU_doDgV78vGm-cYQ@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Andy Adamson [mailto:androsadamson@gmail.com]
> Sent: Thursday, October 11, 2012 1:51 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] NFSv4.1: Kill nfs4_ds_disconnect()
> 
> On Thu, Oct 11, 2012 at 12:51 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > There is nothing to prevent another thread from dereferencing
> > ds->ds_clp during or after the call to nfs4_ds_disconnect(), and
> > Oopsing due to the resulting NULL pointer.
> 
> Yes.
> 
> >
> > Instead, we should just rely on filelayout_mark_devid_invalid() to
> > keep us out of trouble by avoiding that deviceid.
> 
> Why do we want to keep the connection and the nfs_client? For connection
> retry?
> 

The deviceid doesn't really want to keep the nfs_client, but I don't see how you can remove it safely in the current code. There is too much that relies on being able to dereference ds->ds_clp without any locking.

As for the TCP connection: that is a property of the nfs_client and its RPC client, and as such should not be manipulated by pNFS. If there are other users, then they may be waiting for it to reconnect...

