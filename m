Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:60180 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab3JIUsf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Oct 2013 16:48:35 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id B0ECC280162
	for <linux-nfs@vger.kernel.org>; Wed,  9 Oct 2013 22:48:33 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id A48C513E82
	for <linux-nfs@vger.kernel.org>; Wed,  9 Oct 2013 22:48:33 +0200 (MEST)
Date: Wed, 9 Oct 2013 22:48:32 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Andy Adamson <william.adamson@netapp.com>,
        Steve Dickson <steved@redhat.com>
Message-ID: <1667669326.580689.1381351712928.JavaMail.zimbra@desy.de>
In-Reply-To: <1201078747.580554.1381350008792.JavaMail.zimbra@desy.de>
Subject: DoS with NFSv4.1 client
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

last night we got a DoS attack with one of the NFS clients.
The farm node, which was accessing data with pNFS,
went mad and have tried to kill dCache NFS server. As usually
this have happened over night and we was not able to
get a network traffic or bump the debug level.

The symptoms are:

client starts to bombard the MDS with OPEN requests. As we see
state created on the server side, the requests was processed by
server. Nevertheless, for some reason, client did not like it. Here
is the result of mountstats:

OPEN:
	17087065 ops (99%) 	1 retrans (0%) 	0 major timeouts
	avg bytes sent per op: 356	avg bytes received per op: 455
	backlog wait: 0.014707 	RTT: 4.535704 	total execute time: 4.574094 (milliseconds)
CLOSE:
	290 ops (0%) 	0 retrans (0%) 	0 major timeouts
	avg bytes sent per op: 247	avg bytes received per op: 173
	backlog wait: 308.827586 	RTT: 1748.479310 	total execute time: 2057.365517 (milliseconds)


As you can see there is a quite a big difference between number of open and close requests.
The same picture we can see on the server side as well:

NFSServerV41 Stats:                   average±stderr(ns)       min(ns)     max(ns)            Sampes 
  DESTROY_SESSION                          26056±4511.89        13000        97000                17
  OPEN                                    1197297±  0.00       816000  31924558000          54398533
  RESTOREFH                                     0±  0.00            0  25018778000          54398533
  SEQUENCE                                   1000±  0.00         1000  26066722000          55601046
  LOOKUP                                  4607959±  0.00       375000  26977455000             32118
  GETDEVICEINFO                             13158±100.88         4000       655000             11378
  CLOSE                                  16236211±  0.00         5000  21021819000             20420
  LAYOUTGET                             271736361±  0.00     10003000  68414723000             21095

The last column is the number of requests.

This is with RHEL6.4 as the client. By looking at the code,
I can see a loop at nfs4proc.c#nfs4_do_open() which can be
the cause of the problem. Nevertheless, I can't
fine any reason why this look turned into an 'infinite' one.

At the and our server ran out of memory and we have returned
NFSERR_SERVERFAULT to the client. This triggered client to
reestablish the session and all open state ids was
invalidated and cleaned up.

I am still trying to reproduce this behavior (on client
and server) and any hint is welcome.

Tigran.
