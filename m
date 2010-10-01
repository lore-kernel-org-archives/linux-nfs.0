Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57986 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478Ab0JARK3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 13:10:29 -0400
Date: Fri, 1 Oct 2010 13:10:12 -0400
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        NFS list <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>
Subject: Re: pNFS DS session
Message-ID: <20101001171012.GB30570@fieldses.org>
References: <4CA34883.40005@desy.de>
 <4CA34B93.2010100@panasas.com>
 <4CA44AAA.4030803@panasas.com>
 <4CA45462.1070503@desy.de>
 <4CA455C4.4030705@panasas.com>
 <OF6B8488BA.B9C50431-ON882577AF.0016FDCE-882577AF.0017999B@us.ibm.com>
 <4CA57BC6.9030701@desy.de>
 <4CA5A012.2090404@panasas.com>
 <4CA5D537.30300@panasas.com>
 <4CA600F4.2010006@almaden.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA600F4.2010006@almaden.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 01, 2010 at 08:40:36AM -0700, Marc Eshel wrote:
>  On 10/1/2010 5:33 AM, Benny Halevy wrote:
> >On 2010-10-01 10:47, Boaz Harrosh wrote:
> >>On 10/01/2010 08:12 AM, Tigran Mkrtchyan wrote:
> >>>   On 10/01/2010 06:17 AM, Marc Eshel wrote:
> >>>>Hi Benny,
> >>>>
> >>>>Running connectathon I see that some times the clients decides to destroy
> >>>>the session with the DS. The test continue and the session is
> >>>>re-established. It looks like layout return reduces the hold on device
> >>>>info the reduces the hold on the client struct which decide to destroy the
> >>>>session. Is that a known problem?
> >>>>
> >>Yes, I want to emphasize on Marks words: "a known *problem*"
> >Marc, assuming the code behaves as expected, does this cause any other badness
> >like the GETATTRs you see going out to the DS?
> >
> >Benny
> >
> 
> No i don't see any "badness" the test continues without errors and
> this problem is not related to the GETATTRs I see on the DS but I
> would consider destroying the session in short run of couple of
> minutes some times more than one time as something bad.

Why?

I wouldn't expect session destruction/creation to be *that* expensive.

--b.
