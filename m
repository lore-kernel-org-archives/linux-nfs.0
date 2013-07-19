Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760458Ab3GSPJw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 11:09:52 -0400
Date: Fri, 19 Jul 2013 11:09:36 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Should BIND_CONN_TO_SESSION be allowed to return
 NFS4ERR_WRONG_CRED
Message-ID: <20130719150936.GA19297@fieldses.org>
References: <7EC48508-29F6-42DF-9BBA-F90A5CA1A47C@netapp.com>
 <1374159436.3788.3.camel@leira.trondhjem.org>
 <DFCAA8D0-B3BD-49C2-BAC4-9C26668AACB9@netapp.com>
 <1374160910.3788.14.camel@leira.trondhjem.org>
 <1D61D5F4-40DA-47D1-A15A-745EA05813BA@netapp.com>
 <1374167339.3788.52.camel@leira.trondhjem.org>
 <DD04268F-B364-48D0-ADEB-E4770D618B38@netapp.com>
 <9AC7EBEB-E407-4CCB-A6E6-05C24CD821DA@netapp.com>
 <1374177242.3788.59.camel@leira.trondhjem.org>
 <1374177896.3788.67.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1374177896.3788.67.camel@leira.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 18, 2013 at 08:04:58PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-07-18 at 15:54 -0400, Trond Myklebust wrote:
> > On Thu, 2013-07-18 at 19:49 +0000, Adamson, Dros wrote:
> > > Only supporting operations that have the error code NFS4ERR_WRONG_CRED seems to be wrong.  Operations like BIND_CONN_TO_SESSION don't support don't support this error code, but are explicitly mentioned in SP4_MACH_CRED sections of the spec.
> > 
> > Looking at the allowed error return values for BIND_CONN_TO_SESSION, I'm
> > at a loss to figure out exactly what it should return in this case. I
> > suspect that the lack of an NFS4ERR_WRONG_CRED is actually a protocol
> > bug.
> > 
> > Time to go back to the ietf mailing list...
> 
> Hi all,
> 
> When attempting to implement the SP4_MACH_CRED state protection, Dros
> ran into an issue. If the BIND_CONN_TO_SESSION operation is listed in
> the "spo_must_enforce" list of operations, what should it not be allowed
> to return NFS4ERR_WRONG_CRED if called with a credential that is not the
> machine or SSV credential?

For what it's worth, the Linux server is returning WRONG_CRED, as you'd
expect, in this case.  Looks to me like a simple omission from the spec.

--b.
