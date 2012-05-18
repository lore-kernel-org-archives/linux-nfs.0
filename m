Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:41301 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932585Ab2ERADH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 20:03:07 -0400
Subject: Re: [nfs-utils PATCH] build: avoid AM_CONDITIONAL in conditional execution.
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FB5915B.2020800@flameeyes.eu>
Date: Thu, 17 May 2012 20:03:04 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <018E141A-53BE-4445-A563-B3E6BC1E5A08@oracle.com>
References: <1337297671-9614-1-git-send-email-flameeyes@flameeyes.eu> <F2544999-60EA-4192-90D5-44C79DEE82CC@oracle.com> <4FB5915B.2020800@flameeyes.eu>
To: =?iso-8859-1?Q?Diego_Elio_Petten=F2?= <flameeyes@flameeyes.eu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 17, 2012, at 8:01 PM, Diego Elio Pettenò wrote:

> Il 17/05/2012 17:00, Chuck Lever ha scritto:
>> Are we using sqlite3 at all at this point?
> 
> As far as I can tell it's still a requisite for nfsdcld...

OK, I forgot about that.  Never mind.

> I honestly
> haven't looked at the code yet simply because I don't use NFSv4 at all
> (which is why I found this build failure).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




