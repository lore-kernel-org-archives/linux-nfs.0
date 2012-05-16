Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43175 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756371Ab2EPV6s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 17:58:48 -0400
Date: Wed, 16 May 2012 17:58:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: return 0 on reads of fault injection files
Message-ID: <20120516215847.GF20487@fieldses.org>
References: <1336678270-791-1-git-send-email-dros@netapp.com>
 <20120516211621.GE20487@fieldses.org>
 <E560542A-DCC3-4093-8B69-438783DD9451@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <E560542A-DCC3-4093-8B69-438783DD9451@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 16, 2012 at 09:50:32PM +0000, Adamson, Dros wrote:
> No, I haven't messed with it that much - I had other tasks take a
> higher priority, but I'm back on it as of this afternoon.
> 
> I'll try nfsd-next to get CB_PATH_DOWN without fault_injection and
> report back to you.  Also, I think we need to modify nfsd
> (nfsd4_new_conn()) to set cl_cb_state to NFSD4_CB_UNKNOWN on a
> successful BIND_CONN_TO_SESSION (IFF it's CB_DOWN with the right
> direction), otherwise the CB_PATH_DOWN flag will be set on every
> sequence OP

That's intentional:

	http://www.ietf.org/mail-archive/web/nfsv4/current/msg10840.html

> and the client will keep sending BIND_CONN_TO_SESSION.
> The idea is that once we call nfsd4_new_conn, we won't know if the
> back channel is really up until a callback is attempted.

If the client hasn't given us a connection to use as the backchannel,
then we *know* the backchannel is down, we don't need to try sending a
callback (how could we?).

> Setting it to CB_UNKNOWN stops the loop of (sequence, bind_conn,
> sequence, bind_conn, …), but doesn't actually mark it as "UP" until a
> callback is successful.

If the client is attempting to clear the CB_PATH_DOWN flag by sending us
a BIND_CONN_TO_SESSION that doesn't actually give us a backchannel, then
it's confused.

If the client really doesn't care whether the backchannel is down or not
then it can ignore the flag--it's a flag, not an error.

--b.
