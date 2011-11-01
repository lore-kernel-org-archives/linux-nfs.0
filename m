Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42744 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754746Ab1KAOfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 10:35:39 -0400
Date: Tue, 1 Nov 2011 10:35:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111101143538.GE32248@fieldses.org>
References: <1319455259-3136-1-git-send-email-bjschuma@netapp.com>
 <20111028212450.GA7441@fieldses.org>
 <4EAFFD65.4010407@netapp.com>
 <20111101141746.GD32248@fieldses.org>
 <4EB000A6.9040508@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EB000A6.9040508@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 10:22:30AM -0400, Bryan Schumaker wrote:
> On Tue 01 Nov 2011 10:17:46 AM EDT, J. Bruce Fields wrote:
> >> I didn't realize that slabs were initialized in the state_init()
> >> function, I'll fix that.
> >
> > I'll admit that's confusing.  Any suggestion to make it clearer welcome.
> 
> Sure.  The comment after the call to nfs4_state_init() is "nfs4 locking 
> state".  Maybe this could be changed to "nfs4 locking state and slabs"? 
>  I can make this change and send it as a separate patch if you would 
> like.

If there was a way to fix the code itself to make it clearer, that's
usually better--a comment is a workaround.

--b.
