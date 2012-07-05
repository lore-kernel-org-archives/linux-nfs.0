Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:35987 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab2GEVfR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 17:35:17 -0400
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ resulting in hang (BAD_STATEID)
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1341518126.11154.17.camel@lade.trondhjem.org>
Date: Thu, 5 Jul 2012 17:35:12 -0400
Cc: "Charles 'Boyo" <charlesboyo@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <23682B65-4DA9-4966-BF83-C7EC338F9A97@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com> <2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com> <CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com> <2F725B49-A089-41E9-BBC9-11B889A62C9D@oracle.com> <1341263584.8197.53.camel@lade.trondhjem.org> <6C5408EB-668A-43C9-B3FE-9D66427B5BE0@oracle.com> <CAPD_G3KojVhnjtfjN0poJvpV0i+6JZeK54rm5Swm3MDKEXQ=Zw@mail.gmail.com> <1341266386.8197.61.camel@lade.trondhjem.org> <CAPD_G3KS6unxC4qJ1YY1GM-PCbG5sXLC6-aYk6L1dq4Jd0U7MQ@mail.gmail.com> <CAPD_G3LPfHr-2zbv19tL1Bv++ThKbsoqb3XYfZ75CjCrh2Mhxw@mail.gmail.com> <1341518126.11154.17.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 5, 2012, at 3:55 PM, Myklebust, Trond wrote:

> On Thu, 2012-07-05 at 20:23 +0100, Charles 'Boyo wrote:
>>>> What isn't expected behaviour is for the client to DELEGRETURN
>>>> immediately upon receiving the delegation. Nor is it expected that the
>>>> READ would fail to recover in an ordinary DELEGRETURN situation.
>>>> 
>>>> This is why I'm interested in seeing what happened before the OPEN.
>>>> 
>>> 
>>> Attached is a minimally redacted trace which contains all the NFS
>>> calls and responses before and through this particular DELEGRETURN
>>> (frame 6084).
>>> I am unable to provide the full packet capture due to the sensitivity
>>> of the data contained therein.
>> 
>> Trond, did the attached trace confirm the issue as suspected?
>> 
>> Charles
> 
> No. What is happening is that the client does an OPEN of file
> "account.info". It then closes the file and for some reason that I don't
> yet understand, it decides to return the delegation.
> 
> Then the application does another OPEN, which races with the delegation
> return. Because of the race, the server returns the same delegation as
> it did in the first open call. The client (which has now forgotten about
> the original open) sees what it thinks is a new delegation, and so it
> adopts it.
> 
> So this explains why the READs end up trying to use a returned
> delegation. What remains to be explained is:
> 
> a) Why did the client return the delegation in the first place? Is it in
> some extreme memory pressure situation, or does it perhaps have some
> funky setting for /proc/sys/vm/vfs_cache_pressure?
> 
> b) Why doesn't the recovery scenario kick in and do the right thing?

My guess is that EL6.2 kernels don't have the mainline patch that adds support for recovering a single bad state ID.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




