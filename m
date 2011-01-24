Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52286 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1AXWdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 17:33:40 -0500
Message-ID: <4D3DFE40.1070605@panasas.com>
Date: Mon, 24 Jan 2011 17:33:36 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com> <83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
In-Reply-To: <83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-01-24 17:24, Chuck Lever wrote:
> 
> On Jan 24, 2011, at 5:19 PM, Thomas Haynes wrote:
> 
>> I'm being evil here on purpose. :->
>>
>> I'm trying to run cthon04 as downloaded from the connectathon.org repository
>> and I'm getting this:
>>
>>
>> Nroff
>> ./stat: no data in nroff.time
>> general tests failed
>> Tests failed, leaving /cthon04/loghyr mounted
>>
>>
>> As I kinda recall several people fixing this already, where would I go to get patches?
> 
> What are your CFLAGS settings in tests.init?
> 

this is a problem with the version of nroff on newer distributions.
The following patch fixed it for me last bakeathon:

>From f44b150809e43b129fad34e3e4ec288e4dd36e6c Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Wed, 6 Oct 2010 11:37:27 -0400
Subject: [PATCH] cthon nroff general test workaround

Newer versions of nroff spew out a warning that cause the cthon test
to fail in the following way:

Nroff
./stat: no data in nroff.time
general tests failed

The following patch filters out the warning from the output file
generated during the test.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 general/runtests.wrk |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/general/runtests.wrk b/general/runtests.wrk
index f3a5a4e..8247e2f 100644
--- a/general/runtests.wrk
+++ b/general/runtests.wrk
@@ -89,6 +89,8 @@ $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time
 $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time
 rm nroff.out nroff.tbl
 set -e
+egrep -v '^warning:.*$' <nroff.time >nroff.new
+mv -f nroff.new nroff.time
 ./stat nroff.time
 set +e
 
-- 
1.7.3.4

