Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:50224 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696Ab0HCVtf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 17:49:35 -0400
From: <Daniel.Muntz@emc.com>
To: <bfields@fieldses.org>, <rees@umich.edu>
CC: <linux-nfs@vger.kernel.org>
Date: Tue, 3 Aug 2010 17:49:14 -0400
Subject: RE: numeric UIDs
Message-ID: <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com>
References: <201008030401.33552.dreck@vmsd.ath.cx>
 <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org>
In-Reply-To: <20100803192216.GC31579@fieldses.org>
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'll fourth this motion.  The spec goes out of its way to declare this a violation.  IMHO, the NFSv4.[0-n] specs should adopt the convention that a uid string consisting of [0-9]+ be interpreted as the string representation of a numeric UID--just as valid as a "user@domain" string.  There are systems for which the name mapping is unnecessary, or even detrimental to implement.

  -Dan 

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: Tuesday, August 03, 2010 12:22 PM
To: Jim Rees
Cc: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs

On Tue, Aug 03, 2010 at 12:43:18PM -0400, Jim Rees wrote:
> Victor Mataré wrote:
> 
>   I'd like to try and 
>   make a case for implementing an option to turn off UID mapping completely (or 
>   at least for unknown UIDs).
> 
> I've always thought this would be useful too, just as an option for auth_sys
> of course.  Some people think it's a security problem but since there is no
> security in an auth_sys mount I don't see what the issue is.

I'm not sure what the security flavor has to do with it.

I'll admit I like the idea of a v2/v3-compatibility mode that uses
(ascii-encoded) uid's only, though I think it's a technical violation of
the spec.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

