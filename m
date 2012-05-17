Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756945Ab2EQLdG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 07:33:06 -0400
Date: Thu, 17 May 2012 07:33:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: return 0 on reads of fault injection files
Message-ID: <20120517113304.GB25274@fieldses.org>
References: <1336678270-791-1-git-send-email-dros@netapp.com>
 <20120516211621.GE20487@fieldses.org>
 <E560542A-DCC3-4093-8B69-438783DD9451@netapp.com>
 <20120516215847.GF20487@fieldses.org>
 <99C4F6D8-3BBF-4502-B41C-A71B2ADB6207@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <99C4F6D8-3BBF-4502-B41C-A71B2ADB6207@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 16, 2012 at 10:10:55PM +0000, Adamson, Dros wrote:
> 
> On May 16, 2012, at 5:58 PM, J. Bruce Fields wrote:
> 
> > On Wed, May 16, 2012 at 09:50:32PM +0000, Adamson, Dros wrote:
> >> No, I haven't messed with it that much - I had other tasks take a
> >> higher priority, but I'm back on it as of this afternoon.
> >> 
> >> I'll try nfsd-next to get CB_PATH_DOWN without fault_injection and
> >> report back to you.  Also, I think we need to modify nfsd
> >> (nfsd4_new_conn()) to set cl_cb_state to NFSD4_CB_UNKNOWN on a
> >> successful BIND_CONN_TO_SESSION (IFF it's CB_DOWN with the right
> >> direction), otherwise the CB_PATH_DOWN flag will be set on every
> >> sequence OP
> > 
> > That's intentional:
> > 
> > 	http://www.ietf.org/mail-archive/web/nfsv4/current/msg10840.html
> 
> Right...
> 
> > 
> >> and the client will keep sending BIND_CONN_TO_SESSION.
> >> The idea is that once we call nfsd4_new_conn, we won't know if the
> >> back channel is really up until a callback is attempted.
> > 
> > If the client hasn't given us a connection to use as the backchannel,
> > then we *know* the backchannel is down, we don't need to try sending a
> > callback (how could we?).
> 
> The point is that the client *has* given us a connection to use as the backchannel with the BIND_CONN_TO_SESSION call.
> On the server, nfs4_new_conn() was called and was successful, but cl_cb_state is still set to CB_DOWN and will never change.
> 
> > 
> >> Setting it to CB_UNKNOWN stops the loop of (sequence, bind_conn,
> >> sequence, bind_conn, …), but doesn't actually mark it as "UP" until a
> >> callback is successful.
> > 
> > If the client is attempting to clear the CB_PATH_DOWN flag by sending us
> > a BIND_CONN_TO_SESSION that doesn't actually give us a backchannel, then
> > it's confused.
> 
> The client *is* giving us a backchannel by sending the server a BIND_CONNN_TO_SESSION! The server accepts the call, adds the "new connection" via nfs4_new_conn(), but the problem is the internal state of nfsd never changes from CB_DOWN.

Oh, I see, thanks!  Sorry, I was reading too fast....

Yes, your fix sounds about right.

--b.
