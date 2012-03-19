Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38392 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032553Ab2CSTI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 15:08:56 -0400
Date: Mon, 19 Mar 2012 15:08:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, Nikolaus Rath <Nikolaus@rath.org>,
        linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120319190853.GF23670@fieldses.org>
References: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca>
 <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca>
 <20120319173656.GA23670@fieldses.org>
 <126867CF-7CAA-4E3D-A9D6-2A5FE30A7DB4@oracle.com>
 <20120319182712.GB23670@fieldses.org>
 <A39DDC79-274A-427F-9887-28DD74BA56ED@oracle.com>
 <20120319183955.GC23670@fieldses.org>
 <C14ACD08-1D43-44F8-8504-46DCB98359BB@oracle.com>
 <20120319185421.GD23670@fieldses.org>
 <2B0656CB-C28D-411C-A2DD-5FA573498380@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2B0656CB-C28D-411C-A2DD-5FA573498380@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 03:00:57PM -0400, Chuck Lever wrote:
> 
> On Mar 19, 2012, at 2:54 PM, J. Bruce Fields wrote:
> 
> > On Mon, Mar 19, 2012 at 02:42:30PM -0400, Chuck Lever wrote:
> >> 
> >> On Mar 19, 2012, at 2:39 PM, J. Bruce Fields wrote:
> >> 
> >>> On Mon, Mar 19, 2012 at 02:29:46PM -0400, Chuck Lever wrote:
> >>>> 
> >>>> On Mar 19, 2012, at 2:27 PM, J. Bruce Fields wrote:
> >>>>> That's also not this case, sorry, this time with all the conditions:
> >>>>> 
> >>>>> 	- if the nfs_client_id4 is the same, and
> >>>>> 	- if the flavor is auth_sys, and
> >>>>> 	- if the client IP address is different,
> >>>>> 	- then return NFS4ERR_INUSE.
> >>>> 
> >>>> This still breaks for multi-homed servers and UCS clients.  The client IP address can be different depending on what server IP address the client is accessing, but all the other parameters are the same.
> >>> 
> >>> OK.  So probably there's nothing we can do to help here.
> >>> 
> >>> As a bandaid maybe a rate-limited log message ("clientid X now in use
> >>> from IP Y") might help debug these things....
> >> 
> >> Hm, OK.  That implies your server implementation assumes that a clientid4 maps to exactly one client IP address at a time.
> > 
> > OK, agreed.  So how about something like "state for client X previously
> > established from IP Y now cleared from IP Z"  ??
> > 
> > (Assuming it's only the I-just-rebooted setclientid case that's likely
> > to be the sign of a problem.)
> 
> We would see that only in the case where the boot verifier and the client IP change at the same time.  That can happen legitimately, too, if the client has a dynamically assigned IP address.  Maybe this event is only interesting if it happens more than once during the same second.

"Warning: IP addresses Y and Z currently appear to be in a bitter
struggle over client id X"....

That may be getting complicated enough to not be worth it except as a
part of some more general statistics.

--b.
