Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933117Ab1ESQcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2011 12:32:43 -0400
Date: Thu, 19 May 2011 12:32:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC] NFSD: Added basic fault injection
Message-ID: <20110519163242.GC976@fieldses.org>
References: <1305651070-24654-1-git-send-email-bjschuma@netapp.com>
 <20110519000959.GC26545@fieldses.org>
 <4DD5361D.6010304@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD5361D.6010304@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 19, 2011 at 11:24:13AM -0400, Bryan Schumaker wrote:
> On 05/18/2011 08:09 PM, J. Bruce Fields wrote:
> > On Tue, May 17, 2011 at 12:51:10PM -0400, bjschuma@netapp.com wrote:
> >> +void nfsd_forget_all_state_owners(void)
> >> +{
> >> +	struct nfs4_stateowner *sop;
> >> +	struct list_head *pos, *next;
> >> +	int count = 0;
> >> +
> >> +	nfs4_lock_state();
> >> +	list_for_each_safe(pos, next, &close_lru) {
> > 
> > Not all state owners are on the close_lru list--just open owners that
> > have been closed and are waiting to be reaped.
> 
> Ok.  Is the file_hashtbl the right place to look for this?

Probably stateid_hashtbl.

--b.

> I think I'm going to change the function so it only deletes open stateids.
