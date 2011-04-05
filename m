Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepo202.cox.net ([68.230.241.217]:48274 "EHLO
	eastrmfepo202.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab1DEQMO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 12:12:14 -0400
Date: Tue, 5 Apr 2011 11:09:33 -0500
From: Tom Haynes <tdh@excfb.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: secinfo_no_name question
Message-ID: <20110405160933.GA7787@adept.internal.excfb.com>
References: <4D99CAFC.5070402@netapp.com>
 <20110404151412.GA17695@fieldses.org>
 <4D99E237.3030508@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D99E237.3030508@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 04, 2011 at 11:22:31AM -0400, Bryan Schumaker wrote:
> On 04/04/2011 11:14 AM, J. Bruce Fields wrote:
> > On Mon, Apr 04, 2011 at 09:43:24AM -0400, Bryan Schumaker wrote:
> >> Hi Bruce,
> >>
> >> I'm looking at secinfo_no_name on the client.  RFC 5661 says to says to send PUTROOTFH followed by SECINFO_NO_NAME in the same compound and to use SECINFO_STYLE4_CURRENT_FH.  My compound is: SEQUENCE, PUTROOTFH, SECINFO_NO_NAME.  The server processes up to the PUTROOTFH, and then returns with NFS4ERR_WRONGSEC.  
> >>
> >> Am I doing something wrong?  Is this a server problem?
> > 
> > Could be; is the compound is being sent with a security flavor that
> > *isn't* permitted on the root export?

It should never fail:

2.6.3.1.1.5.  Put Filehandle Operation + SECINFO/SECINFO_NO_NAME

...

   The NFSv4.1 server MUST NOT return NFS4ERR_WRONGSEC to a put
   filehandle operation that is immediately followed by SECINFO or
   SECINFO_NO_NAME.  The NFSv4.1 server MUST NOT return NFS4ERR_WRONGSEC
   from SECINFO or SECINFO_NO_NAME.


> > 
> > If so I believe the compound should have succeeded--the server needs
> > some special exception there that we may have left out....
> 
> The root export is set up with sec=null and my compound is using auth_unix.  
> 
> > 
> > --b.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Tom Haynes
ex-cfb
