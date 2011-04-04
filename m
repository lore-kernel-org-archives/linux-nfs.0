Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40605 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269Ab1DDPON (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Apr 2011 11:14:13 -0400
Date: Mon, 4 Apr 2011 11:14:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: secinfo_no_name question
Message-ID: <20110404151412.GA17695@fieldses.org>
References: <4D99CAFC.5070402@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D99CAFC.5070402@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 04, 2011 at 09:43:24AM -0400, Bryan Schumaker wrote:
> Hi Bruce,
> 
> I'm looking at secinfo_no_name on the client.  RFC 5661 says to says to send PUTROOTFH followed by SECINFO_NO_NAME in the same compound and to use SECINFO_STYLE4_CURRENT_FH.  My compound is: SEQUENCE, PUTROOTFH, SECINFO_NO_NAME.  The server processes up to the PUTROOTFH, and then returns with NFS4ERR_WRONGSEC.  
> 
> Am I doing something wrong?  Is this a server problem?

Could be; is the compound is being sent with a security flavor that
*isn't* permitted on the root export?

If so I believe the compound should have succeeded--the server needs
some special exception there that we may have left out....

--b.
