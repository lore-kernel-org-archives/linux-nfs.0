Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:60466 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab2GETXx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 15:23:53 -0400
Received: by ghrr11 with SMTP id r11so7807413ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jul 2012 12:23:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPD_G3KS6unxC4qJ1YY1GM-PCbG5sXLC6-aYk6L1dq4Jd0U7MQ@mail.gmail.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
	<2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com>
	<CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com>
	<2F725B49-A089-41E9-BBC9-11B889A62C9D@oracle.com>
	<1341263584.8197.53.camel@lade.trondhjem.org>
	<6C5408EB-668A-43C9-B3FE-9D66427B5BE0@oracle.com>
	<CAPD_G3KojVhnjtfjN0poJvpV0i+6JZeK54rm5Swm3MDKEXQ=Zw@mail.gmail.com>
	<1341266386.8197.61.camel@lade.trondhjem.org>
	<CAPD_G3KS6unxC4qJ1YY1GM-PCbG5sXLC6-aYk6L1dq4Jd0U7MQ@mail.gmail.com>
Date: Thu, 5 Jul 2012 20:23:52 +0100
Message-ID: <CAPD_G3LPfHr-2zbv19tL1Bv++ThKbsoqb3XYfZ75CjCrh2Mhxw@mail.gmail.com>
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ
 resulting in hang (BAD_STATEID)
From: "Charles 'Boyo" <charlesboyo@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> What isn't expected behaviour is for the client to DELEGRETURN
>> immediately upon receiving the delegation. Nor is it expected that the
>> READ would fail to recover in an ordinary DELEGRETURN situation.
>>
>> This is why I'm interested in seeing what happened before the OPEN.
>>
>
> Attached is a minimally redacted trace which contains all the NFS
> calls and responses before and through this particular DELEGRETURN
> (frame 6084).
> I am unable to provide the full packet capture due to the sensitivity
> of the data contained therein.

Trond, did the attached trace confirm the issue as suspected?

Charles
