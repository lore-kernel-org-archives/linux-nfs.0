Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25177 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1AYNnq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 08:43:46 -0500
Message-ID: <4D3ED37D.6020606@netapp.com>
Date: Tue, 25 Jan 2011 08:43:25 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Chuck Lever <chuck.lever@oracle.com>, Thomas Haynes <thomas@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com> <83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com> <4D3DFE40.1070605@panasas.com>
In-Reply-To: <4D3DFE40.1070605@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/24/2011 05:33 PM, Benny Halevy wrote:
> this is a problem with the version of nroff on newer distributions.

My version of groff (1.21) is splitting the error into two lines, so I am using the following patch.

Bryan


--- a/general/runtests.wrk

+++ a/general/runtests.wrk

@@ -88,6 +88,12 @@

 $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time

 $TIME nroff < nroff.tbl > nroff.out 2>> nroff.time || cat nroff.time

 rm nroff.out nroff.tbl

+# Filter excessive noise from GNU nroff.  Should be harmless for other

+# versions of nroff.

+egrep -v '^warning:.*$' <nroff.time >nroff.new

+mv -f nroff.new nroff.time

+egrep -v '^  table wider.*$' <nroff.time >nroff.new

+mv -f nroff.new nroff.time

 set -e

 ./stat nroff.time

 set +e



