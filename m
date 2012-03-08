Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48876 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794Ab2CHUmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 15:42:08 -0500
Date: Thu, 8 Mar 2012 15:42:05 -0500
To: Olga Kornievskaia <aglo@citi.umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Return the delegation if the server returns
 NFS4ERR_OPENMODE
Message-ID: <20120308204205.GB9273@fieldses.org>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
 <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
 <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
 <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
 <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com>
 <1331230525.2472.39.camel@lade.trondhjem.org>
 <CAN-5tyFYE5ECtv__C9S_GMT1gBMQ4+6WPS-1BjmSE7vHoRAQdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFYE5ECtv__C9S_GMT1gBMQ4+6WPS-1BjmSE7vHoRAQdw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 08, 2012 at 03:23:34PM -0500, Olga Kornievskaia wrote:
> On Thu, Mar 8, 2012 at 1:15 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> > On Thu, 2012-03-08 at 12:52 -0500, Olga Kornievskaia wrote:
> >> wouldn't it be better for you to proactively return a read delegation
> >> then unnecessarily erroring?
> >
> > If nobody else holds a delegation, then the NFS client is actually
> > allowed to keep its read delegation while writing to the file. It does
> > admittedly need to request an OPEN stateid for write in that case...
> > (See section 10.4 of RFC3530bis draft 16)
> 
> If we both agree that there has to be a request for an open stateid for
> a write, then instead of returning the read delegation if the client receives
> err_openmode (when it send the request with read delegation stateid
> as you said per 3560bis), can't the client resend the setattr with the open
> stateid? The ordering of the stateid usage is a "should" and not a "must".
> 
> In rfc5661, it really doesn't make sense to ever send a setattr with
> a read delegation stateid. According to 9.1.2, the server "MUST" return
> err_open_mode" error in that case.
> 
> I gather you are in this case dealing with 4.0 delegations. But I wonder
> if you'll do something else for 4.1 delegation then?

3530bis has the same language ("...must verify that the access mode
allows writing and return an NFS4ERR_OPENMODE error if it does not").

--b.

> 
> Another comment is that I was suggesting a return of delegation only
> because (from what i recall) the 4.1 servers out there will recall the
> previously
> given read delegation in this case.
> 
> > That said, in either case we do need to deal with the fact that a new
> > delegation may be granted after we return the old one. There is no
> > locking around the setattr call to prevent this.
> 
> Can that really happen since we agreed that the client also has an open
> stateid for write in this case?
> 
> >> i also don't understand how this error occurs. doing a setattr in this
> >> case you must have used a non-special stateid. the server would only
> >> return an err_openmode if you sent the setattr with a read delegation
> >> stateid. i guess my question is what stateid would you use that from
> >> client's perspective represent a write-type state id but yet a server
> >> would flag as having wrong access type?
> >
> > The read delegation stateid is being sent as per the prescription in
> > section 9.1.3.6 of RFC3530bis.
> 
> >> also i'm curious why would a server, instead of returning
> >> err_openmode, would not first recall your read delegation?
> >
> > It could, but why do so when it can just return an error value? The
> > presence of the delegation stateid in the SETATTR request allows it to
> > communicate directly to the client what the problem is without the need
> > for any callbacks.
> 
> > Trond Myklebust
> > Linux NFS client maintainer
> >
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
