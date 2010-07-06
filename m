Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22215 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754185Ab0GFNUg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 09:20:36 -0400
Message-ID: <4C332DA1.60204@panasas.com>
Date: Tue, 06 Jul 2010 16:20:33 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Sandeep Joshi <sjoshi@bluearc.com>
CC: linux-nfs@vger.kernel.org, NFSv4 <nfsv4@ietf.org>
Subject: Re: 4.1 client - LAYOUTCOMMIT
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
In-Reply-To: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jul. 02, 2010, 2:47 +0300, "Sandeep Joshi" <sjoshi@bluearc.com> wrote:
> 
> As per specification value of newoffset4_u.no_offset should be less than or equal to NFS4_MAXFILEOFF.
> But, I observe it to be NFS4_MAXFILELEN.

No.
The last offset the client can access is NFS4_MAXFILEOFF.
Writing a single byte in NFS4_MAXFILEOFF will result in a file
with length NFS4_MAXFILELEN but the loca_last_write_offset
in this case is NFS4_MAXFILEOFF.

Benny

> 
> 
> regards,
> 
> Sandeep
