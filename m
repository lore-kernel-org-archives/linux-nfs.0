Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13883 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab1DDPWd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Apr 2011 11:22:33 -0400
Message-ID: <4D99E237.3030508@netapp.com>
Date: Mon, 04 Apr 2011 11:22:31 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: secinfo_no_name question
References: <4D99CAFC.5070402@netapp.com> <20110404151412.GA17695@fieldses.org>
In-Reply-To: <20110404151412.GA17695@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/04/2011 11:14 AM, J. Bruce Fields wrote:
> On Mon, Apr 04, 2011 at 09:43:24AM -0400, Bryan Schumaker wrote:
>> Hi Bruce,
>>
>> I'm looking at secinfo_no_name on the client.  RFC 5661 says to says to send PUTROOTFH followed by SECINFO_NO_NAME in the same compound and to use SECINFO_STYLE4_CURRENT_FH.  My compound is: SEQUENCE, PUTROOTFH, SECINFO_NO_NAME.  The server processes up to the PUTROOTFH, and then returns with NFS4ERR_WRONGSEC.  
>>
>> Am I doing something wrong?  Is this a server problem?
> 
> Could be; is the compound is being sent with a security flavor that
> *isn't* permitted on the root export?
> 
> If so I believe the compound should have succeeded--the server needs
> some special exception there that we may have left out....

The root export is set up with sec=null and my compound is using auth_unix.  

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

