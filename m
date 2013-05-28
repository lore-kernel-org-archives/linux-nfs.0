Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54692 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934463Ab3E1PIV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 11:08:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>, nfsv4 mailing list <nfsv4@ietf.org>,
        Idan Keidar <idank@tonian.com>, Lev Solomonov <solo@tonian.com>,
        Nadav Shemer <nadav@tonian.com>, "Welch, Brent" <welch@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>, Peng Tao <peng_tao@emc.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: Client security considerations for out of band I/O
Date: Tue, 28 May 2013 15:08:18 +0000
Message-ID: <1369753692.5870.38.camel@leira.trondhjem.org>
References: <51A4A830.5040103@tonian.com>
In-Reply-To: <51A4A830.5040103@tonian.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-05-28 at 15:50 +0300, Benny Halevy wrote:
> Trond, with the latest code for issuing LAYOUTGET with the right credentials
> we still seem to have a problem with the objects and blocks layout where
> the security enforcement over out-of-band I/O differs from than the one
> over in-band I/O.
> 
> Consider the following scenario:
> 
> file is owned by <uid1, gid1>, mode 660
> process p1 successfully opens the file for RW with <uid1, gid1> (client sent OPEN)
> process p2 successfully opens the file for RW with <uid2, gid1> (client sent ACCESS)
> client gets a layout using LAYOUTGET for IOMODE_RW
> the file is chmod'ed to 600
> 
> now, empirically, in-band I/O would succeed for p1 and fail for p2 (as seen on linux
> and some commercial servers)
> 
> for out-of-band I/O, an object-based server will fence-off the object and recall the layout
> to enforce the client to refresh its layout, send a LAYOUTGET, reauthorize, and get
> a new capability. BUT, that's not enough as the new layout and capability, would allow both
> p1 and p2 access to the object (as the layout is global to the client), yet we want only p1
> to have access now.

I don't understand why you think this is related to the LAYOUTGET
credential change. The only difference that the credential change brings
is to the case where the client doesn't hold a layout segment prior to
initiating the read/writeback.

IOW: If p1 had already grabbed a layout segment covering the area being
accessed by p2, then under the old code, we would still have forged
ahead and performed the read/write on the DS without calling LAYOUTGET
at all.

> How about sending ACCESS for any principal before using a newly retrieved layout
> at OPEN time or after the layout was revoked/reacquired to simulate the in-band behavior in
> a practical manner?

If you want to do that for the objects and blocks layout types, then
fine, but I see no reason to do it for files layouts: the files DSes
will do access checking using the cred passed with the READ/WRITE
regardless of what happened with LAYOUTGET.

> Note that I expect some inaccuracies in behavior even with sending ACCESS as
> the linux nfs server and other commercial servers bypass permission checking for the file owner
> at I/O time but not for ACCESS.  I believe this was done to simulate (sort of) Posix behavior
> that allows I/O to an open file even after changing its security attributes.
>
> Also, do we deal correctly with LAYOUTGET failing on NFS4ERR_ACCESS?
> In the example above, if the open order was reversed, LAYOUTGET would have failed for p2's
> creds as it doesn't have RW access to the file.  That would result to reverting to the MDS
> and the I/O would fail on NFS4ERR_ACCESS as well, yet we'll keep trying (and failing)
> LAYOUTGET.  Optionally, the client could try other creds that opened the file.
> If the first process to open the file closes it, should we use different creds for LAYOUTGET?
> With the latest implementation we keep the first opener creds referenced until we return the
> whole layout, right?

I'm open to the idea of having an NFS4ERR_ACCESS reply to LAYOUTGET fail
the entire I/O attempt without an attempt to fail back to MDS.

As for switching creds on close, I believe that is still forbidden under
the rules guiding the EXCHGID4_FLAG_BIND_PRINC_STATEID flag (RFC5661,
section 18.35.3). Under those rules, a server that sets the
EXCHGID4_FLAG_BIND_PRINC_STATEID in the EXCHANGE_ID reply MUST return
NFS4ERR_WRONG_CRED in response to the LAYOUTGET call if it tries to
authenticate a layout or open stateid that was created by p1, using the
principal of p2.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
