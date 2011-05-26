Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58090 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757986Ab1EZOQj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 10:16:39 -0400
Subject: Re: [RFC] pnfs: Send layoutreturn, if Return-On-Close is set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Thu, 26 May 2011 10:16:37 -0400
In-Reply-To: <4DDE536E.8020805@panasas.com>
References: <4DDE536E.8020805@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306419397.2984.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-26 at 16:19 +0300, Boaz Harrosh wrote: 
> Every thing was ready, in pnfs_roc(). The segments released
> and the LO state blocked til after the close is done. All that
> is needed is to send the actual layoutreturn synchronously.

Why would we want to do this?

Return-on-close was initially considered useful only for debugging.

At the interim IETF meeting in Sunnyvale, we also discussed the case
where the forgetful client has forgotten the layout: in this case the
server may decide to forget the layout too. There is no controversy in
doing this, since both the client and the server know that any
outstanding layout is supposed to be returned (and if there is a
problem, then the server always has the option of sending a
CB_LAYOUTRECALL).

Adding a synchronous call to close is in any case a bug since close can
on occasion be sent in situations where we don't allow sleeping.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

