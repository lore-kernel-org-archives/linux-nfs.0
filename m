Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34489 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644Ab1DJQZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:25:39 -0400
Date: Sun, 10 Apr 2011 12:25:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: secinfo_no_name question
Message-ID: <20110410162536.GC26233@fieldses.org>
References: <4D99CAFC.5070402@netapp.com>
 <20110404151412.GA17695@fieldses.org>
 <4D99E237.3030508@netapp.com>
 <20110405160933.GA7787@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110405160933.GA7787@adept.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 05, 2011 at 11:09:33AM -0500, Tom Haynes wrote:
> On Mon, Apr 04, 2011 at 11:22:31AM -0400, Bryan Schumaker wrote:
> > On 04/04/2011 11:14 AM, J. Bruce Fields wrote:
> > > On Mon, Apr 04, 2011 at 09:43:24AM -0400, Bryan Schumaker wrote:
> > >> Hi Bruce,
> > >>
> > >> I'm looking at secinfo_no_name on the client.  RFC 5661 says to says to send PUTROOTFH followed by SECINFO_NO_NAME in the same compound and to use SECINFO_STYLE4_CURRENT_FH.  My compound is: SEQUENCE, PUTROOTFH, SECINFO_NO_NAME.  The server processes up to the PUTROOTFH, and then returns with NFS4ERR_WRONGSEC.  
> > >>
> > >> Am I doing something wrong?  Is this a server problem?
> > > 
> > > Could be; is the compound is being sent with a security flavor that
> > > *isn't* permitted on the root export?
> 
> It should never fail:
> 
> 2.6.3.1.1.5.  Put Filehandle Operation + SECINFO/SECINFO_NO_NAME
> 
> ...
> 
>    The NFSv4.1 server MUST NOT return NFS4ERR_WRONGSEC to a put
>    filehandle operation that is immediately followed by SECINFO or
>    SECINFO_NO_NAME.  The NFSv4.1 server MUST NOT return NFS4ERR_WRONGSEC
>    from SECINFO or SECINFO_NO_NAME.

And I thought I'd implemented those recommendations at some point--I
guess not!  My attempt follows.

--b.
